"""Compare rendered DOM blocks, ignoring vertical movement caused by insertions."""
from difflib import SequenceMatcher
from collections import Counter
from pathlib import Path
import json

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

# Browser capture is bounded to 120 million pixels; long mobile lectures can
# exceed Pillow's default warning threshold. Published crops stay below 10 MP.
Image.MAX_IMAGE_PIXELS = 150_000_000


def crop(image, block):
    return image.crop((0, max(0, round(block['top'])), image.width,
                       min(image.height, max(round(block['top']) + 1, round(block['bottom'])))))


def differs(a, b):
    if abs(a.width - b.width) > 1 or abs(a.height - b.height) > 2:
        return True
    # Subpixel rasterization can shift with the vertical position of an unchanged block.
    width,height=min(a.width,b.width),min(a.height,b.height)
    a=a.convert('RGB').filter(ImageFilter.GaussianBlur(.7))
    b=b.convert('RGB').filter(ImageFilter.GaussianBlur(.7))
    if height<7:return False
    for offset in (-2,-1,0,1,2):
        delta=ImageChops.difference(a.crop((0,2,width,height-2)),b.crop((0,2+offset,width,height-2+offset)))
        changed=delta.convert('L').point(lambda x:255 if x>40 else 0).histogram()[255]
        if changed/max(1,width*(height-4))<=.012:return False
    return True


def changed_blocks(left, right, old, new):
    a, b = left['blocks'], right['blocks']
    changes = []
    counts_a=Counter(x['key'] for x in a)
    counts_b=Counter(x['key'] for x in b)
    def block_changed(x,y):
        if x['styles']!=y['styles'] or abs((x['bottom']-x['top'])-(y['bottom']-y['top']))>2 or abs(x.get('width',0)-y.get('width',0))>2:
            return True
        # Equal text, styles and layout can rasterize slightly differently after
        # moving by a fractional CSS pixel. Only artwork (or changed font files)
        # needs a pixel comparison in addition to the semantic/style comparison.
        raster=x.get('visual',True) or y.get('visual',True) or left.get('font_hash')!=right.get('font_hash')
        return raster and differs(crop(old,x),crop(new,y))
    matcher = SequenceMatcher(None, [x['key'] for x in a], [x['key'] for x in b], autojunk=False)
    for tag, i, j, k, l in matcher.get_opcodes():
        if tag == 'equal':
            for ai, bi in zip(range(i, j), range(k, l)):
                if block_changed(a[ai],b[bi]):
                    changes.append((ai, ai+1, bi, bi+1))
        else:
            # Do not call unchanged content a deletion merely because its order changed.
            if tag in ('delete', 'insert'):
                source, other = (a[i:j], b) if tag == 'delete' else (b[k:l], a)
                source_counts,other_counts=(counts_a,counts_b) if tag=='delete' else (counts_b,counts_a)
                source_image, other_image = (old, new) if tag == 'delete' else (new, old)
                if all(source_counts[x['key']]<=other_counts[x['key']] and any(x['key'] == y['key'] and x['styles'] == y['styles']
                           and not differs(crop(source_image, x), crop(other_image, y))
                           for y in other) for x in source):
                    continue
            changes.append((i, j, k, l))
    merged = []
    for i, j, k, l in changes:
        if merged and i <= merged[-1][1]+1 and k <= merged[-1][3]+1:
            p, q, r, s = merged.pop()
            merged.append((p, max(q,j), r, max(s,l)))
        else:
            merged.append((i,j,k,l))
    return merged


def strip(image, blocks, start, end):
    if start == end:
        return None
    return image.crop((0, max(0, int(blocks[start]['top'])-3), image.width,
                       min(image.height, int(blocks[end-1]['bottom'])+4)))


def join(images):
    images=[image for image in images if image is not None]
    if not images:
        return None
    result=Image.new('RGB',(max(image.width for image in images),sum(image.height for image in images)+6*(len(images)-1)),'white')
    top=0
    for image in images:
        result.paste(image,(0,top))
        top+=image.height+6
    return result


def panels(left, right, output, stem, metadata, leading=(None,None), trailing=(None,None)):
    height = 1100
    count = max(1, *((image.height+height-1)//height for image in (left,right) if image))
    result = []
    for part in range(count):
        a = left.crop((0,part*height,left.width,min(left.height,(part+1)*height))) if left and part*height<left.height else None
        b = right.crop((0,part*height,right.width,min(right.height,(part+1)*height))) if right and part*height<right.height else None
        a=join([leading[0] if part==0 else None,a,trailing[0] if part==count-1 else None])
        b=join([leading[1] if part==0 else None,b,trailing[1] if part==count-1 else None])
        # Continuations without an old/new counterpart use one column.
        columns = [(a,'BEFORE','#b42332'),(b,'AFTER','#197539')]
        columns = [x for x in columns if x[0]]
        canvas = Image.new('RGB',(sum(x[0].width for x in columns)+12*(len(columns)+1), max(x[0].height for x in columns)+46),'#e9eef3')
        draw = ImageDraw.Draw(canvas)
        x = 12
        for image,label,color in columns:
            draw.text((x,10),f'{label} | {metadata["viewport"]}px | part {part+1}/{count}',fill=color,font=ImageFont.load_default(size=18))
            canvas.paste(image,(x,34))
            x += image.width+12
        name = f'{stem}-{part+1}.png'
        canvas.save(output/name)
        result.append(dict(file=name,**metadata))
    return result


def compare(browser_folder, output):
    data = json.loads((browser_folder/'browser.json').read_text(encoding='utf-8'))
    pages = {(p['side'],p['page'],p['viewport']):p for p in data['pages']}
    regions=[]
    for page,width in sorted({(p['page'],p['viewport']) for p in data['pages']}):
        left = pages.get(('before',page,width),dict(blocks=[]))
        right = pages.get(('after',page,width),dict(blocks=[]))
        old = Image.open(browser_folder/left['image']).convert('RGB') if 'image' in left else Image.new('RGB',(width,1),'white')
        new = Image.open(browser_folder/right['image']).convert('RGB') if 'image' in right else Image.new('RGB',(width,1),'white')
        for n,(i,j,k,l) in enumerate(changed_blocks(left,right,old,new)):
            # Include one preceding/following block. Do not repeat it in continuation panels.
            a=strip(old,left['blocks'],i,j)
            b=strip(new,right['blocks'],k,l)
            def context(image,blocks,index,before):
                if index<0 or index>=len(blocks):return None
                image=crop(image,blocks[index])
                return image.crop((0,max(0,image.height-200) if before else 0,image.width,image.height if before else min(200,image.height)))
            leading=(context(old,left['blocks'],i-1,True),context(new,right['blocks'],k-1,True))
            trailing=(context(old,left['blocks'],j,False),context(new,right['blocks'],l,False))
            regions.extend(panels(a,b,output,f'{Path(page).stem}-{width}-{n+1}',dict(page=page,viewport=width),leading,trailing))
            if len(regions)>=120:
                return regions,True
    return regions,False

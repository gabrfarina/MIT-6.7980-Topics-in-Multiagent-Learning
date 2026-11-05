// Six sequential frames explain information, a realized example, and its limits.
#set page(width: auto, height: auto, margin: 2mm, fill: white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.4.1"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let blue=rgb("#2864a5")
  let orange=rgb("#bd5c1d")
  let faint=luma(77%)
  let w=5.25
  let h=2.35
  let axes(x,y,label)={
    for v in (0,.5,1) {
      line((x+v*w,y),(x+v*w,y+h),stroke: .25pt+luma(90%))
      line((x,y+v*h),(x+w,y+v*h),stroke: .25pt+luma(90%))
      content((x+v*w,y - .2),anchor:"north",text(size:8.5pt)[#str(v)])
      content((x - .16,y+v*h),anchor:"east",text(size:8.5pt)[#str(v)])
    }
    line((x,y),(x+w+.08,y),stroke:.65pt)
    line((x,y),(x,y+h+.08),stroke:.65pt)
    content((x+w/2,y - .72),[Forecast $p$])
    content((x - .9,y+h/2),angle:90deg,text(size:9pt)[#label])
  }
  let diagonal(x,y)={
    line((x,y),(x+w,y+h),stroke:(paint:luma(65%),thickness:.6pt,dash:"dashed"))
  }
  let point(x,y,q,r,color:blue)={
    circle((x+q*w,y+r*h),radius:.095,fill:color,stroke:color)
  }
  let heading(x,y,t)={
    content((x+.1,y+5.35),anchor:"north-west",block(width:7.25cm)[*#t*])
  }
  let footer(x,y,t)={
    content((x+.1,y+.35),anchor:"north-west",block(width:7.25cm)[#t])
  }

  // Read across each row, then down. No decorative panel borders.
  for yy in (0,6.7,13.4) {
    line((7.55,yy+2.8),(8.03,yy+2.8),stroke:.7pt+luma(65%),mark:(end:"stealth",scale:.5))
  }

  // 1. If actual forecasts are visible, Nature can lock each bucket to one outcome.
  let (x,y)=(0,13.4)
  heading(x,y,[1. Seeing the forecast lets Nature target it])
  let (a,b)=(x+.95,y+1.65)
  axes(a,b,[Nature's outcome $y$])
  diagonal(a,b)
  line((a,b+h),(a+w/2,b+h),stroke:1pt+orange)
  line((a+w/2,b),(a+w,b),stroke:1pt+orange)
  circle((a+w/2,b+h),radius:.065,fill:white,stroke:orange)
  circle((a+w/2,b),radius:.065,fill:orange,stroke:orange)
  for (q,r) in ((.25,1),(.75,0)) {
    line((a+q*w,b+q*h),(a+q*w,b+r*h),stroke:1.2pt+blue)
    point(a,b,q,r)
    content((a+q*w+.16,b+(.5*q+.5*r)*h),anchor:"west",text(fill:blue,size:9pt)[0.75])
  }
  footer(x,y,[Report 0.25: Nature chooses 1; report 0.75: it chooses 0. Both bucket gaps are 0.75.])

  // 2. Public distribution is not a public realization. A hidden outcome is committed first.
  let (x,y)=(8.3,13.4)
  heading(x,y,[2. Publish the lottery; Nature commits first])
  let (a,b)=(x+.95,y+1.65)
  axes(a,b,[Draw chance])
  for q in (.25,.75) {
    line((a+q*w,b),(a+q*w,b+h/2),stroke:1.4pt+blue)
    point(a,b,q,.5)
    content((a+q*w,b+h/2+.32),[$1/2$])
  }
  footer(x,y,[Both forecasts have draw chance 1/2. Nature fixes $y$ before the draw and keeps it hidden from the forecaster.])

  // 3. The particular realization is private; p=.75 does not mean draw probability .75.
  let (x,y)=(0,6.7)
  heading(x,y,[3. A private coin selects the actual forecast])
  let (a,b)=(x+.95,y+1.65)
  axes(a,b,[Draw chance])
  line((a+.25*w,b),(a+.25*w,b+h/2),stroke:1pt+faint)
  point(a,b,.25,.5,color:faint)
  line((a+.75*w,b),(a+.75*w,b+h/2),stroke:1.7pt+blue)
  circle((a+.75*w,b+h/2),radius:.19,fill:blue.transparentize(80%),stroke:none)
  point(a,b,.75,.5)
  content((a+.75*w,b+h/2+.4),text(fill:blue)[$p=0.75$])
  footer(x,y,[This draw selects forecast 0.75, with chance 1/2. Nature has already committed; the forecaster still does not know $y$.])

  // 4. One illustrative branch: Nature had committed y=1; it cannot now switch to 0.
  let (x,y)=(8.3,6.7)
  heading(x,y,[4. Reveal the outcome; no last-second switch])
  let (a,b)=(x+.95,y+1.65)
  axes(a,b,[Revealed outcome $y$])
  diagonal(a,b)
  line((a,b+h),(a+w,b+h),stroke:(paint:orange,thickness:.8pt,dash:"dashed"))
  point(a,b,.75,1)
  line((a+.75*w,b+.75*h),(a+.75*w,b+h),stroke:1.3pt+blue)
  content((a+.75*w - .12,b+.875*h),anchor:"east",text(fill:blue,size:9pt)[0.25])
  let c=(a+.75*w,b)
  circle(c,radius:.09,fill:white,stroke:faint)
  line((c.at(0) - .12,c.at(1) - .12),(c.at(0)+.12,c.at(1)+.12),stroke:1pt+orange)
  line((c.at(0) - .12,c.at(1)+.12),(c.at(0)+.12,c.at(1) - .12),stroke:1pt+orange)
  footer(x,y,[Here Nature committed $y=1$. On seeing $p=0.75$, it cannot switch to the old threshold response $y=0$.])

  // 5. A possible recorded trace, not an algorithmic guarantee.
  let (x,y)=(0,0)
  heading(x,y,[5. One possible four-round record])
  let (a,b)=(x+.95,y+1.65)
  axes(a,b,[Bucket frequency])
  diagonal(a,b)
  for q in (.25,.75) {
    line((a+q*w,b+q*h),(a+q*w,b+h/2),stroke:1.2pt+blue)
    point(a,b,q,.5)
    content((a+q*w,b+h+.28),[$(1,0)$])
  }
  footer(x,y,[Each bucket receives one 1 and one 0: both frequencies are 0.5, so ECE is 0.25 on this record.])

  // 6. Fixed randomization still fails; suitable history-dependent strategies matter.
  let (x,y)=(8.3,0)
  heading(x,y,[6. Randomness needs a suitable strategy])
  let (a,b)=(x+.95,y+1.65)
  axes(a,b,[Bucket frequency])
  diagonal(a,b)
  for q in (.25,.75) {
    line((a+q*w,b+q*h),(a+q*w,b+h),stroke:1.2pt+orange)
    point(a,b,q,1,color:orange)
  }
  footer(x,y,[Keep this lottery forever against all-one outcomes: $EE["ECE"]=0.5$. A successful strategy must use the history.])
})

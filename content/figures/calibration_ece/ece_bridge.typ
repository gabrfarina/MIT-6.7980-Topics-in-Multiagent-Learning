// The same full 11-record history is used in both panels.
#set page(width:auto,height:auto,margin:2mm,fill:white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font:figure-font,size:9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#cetz.canvas(length:1cm,{
 import cetz.draw: *
 let blue=rgb("#2864a5")
 let orange=rgb("#bd5c1d")
 let gray=luma(55%)
 content((0,11.2),anchor:"west",[*1. Four next records: absolute values first, then average over draws*])
 let xx(v)=1.5+(v - .4)/.16*13
 let old=23/44
 line((xx(old),6.5),(xx(old),10.4),stroke:(paint:gray,thickness:.8pt,dash:"dashed"))
 content((xx(old),10.65),text(fill:gray,size:9pt)[Old ECE: 0.5227])
 for (y,row,lo,hi,avg) in ((0,9.4,11/24,25/48,.5),(1,7.3,13/24,7/16,17/36)){
  content((0,row),anchor:"west",[$y=#y$])
  line((xx(lo),row),(xx(hi),row),stroke:.5pt+luma(75%))
  for (v,color,p,label) in ((lo,blue,[0.25],[1/3]),(hi,orange,[0.50],[2/3])){
   circle((xx(v),row),radius:.11,fill:color,stroke:none)
   content((xx(v),row+.5),text(fill:color,size:9pt)[$p=#p$: #calc.round(v,digits:4)])
   content((xx(v),row - .45),text(fill:color,size:8.5pt)[Draw chance: #label])
  }
  line((xx(avg),row - .15),(xx(avg)+.15,row),(xx(avg),row+.15),(xx(avg) - .15,row),(xx(avg),row - .15),close:true,fill:black,stroke:none)
  content((xx(avg),row - .95),text(size:9pt)[Mean: #calc.round(avg,digits:4)])
 }
 line((xx(.4),6.0),(xx(.56),6.0),stroke:.6pt)
 for v in (.4,.45,.5,.55){content((xx(v),5.75),text(size:8.5pt)[#str(v)])}
 content((8,5.35),[ECE of the complete 12-record history])
 content((0,4.8),anchor:"west",[*2. Historical bucket gaps: their root mean square bounds ECE*])
 let (x,y,w,h)=(1.5,.6,13,3.2)
 for v in (0,.5,1){
  line((x,y+v*h),(x+w,y+v*h),stroke:.25pt+luma(88%))
  content((x - .2,y+v*h),anchor:"east",text(size:8.5pt)[#str(v)])
 }
 let left=0
 for (q,n,gap) in ((0,1,1),(.25,4,.5),(.5,4,.25),(.75,1,.75),(1,1,1)){
  let width=w*n/11
  rect((x+left,y),(x+left+width,y+gap*h),fill:blue.lighten(82%),stroke:.5pt+blue)
  content((x+left+width/2,y+gap*h+if gap==.5 { - .35} else {.18}),text(size:8.5pt)[#str(gap)])
  content((x+left+width/2,y - .24),text(size:8pt)[$#q$])
  left+=width
 }
 line((x,y+23/44*h),(x+w,y+23/44*h),stroke:1.25pt+blue)
 line((x,y+calc.sqrt(61/176)*h),(x+w,y+calc.sqrt(61/176)*h),stroke:(paint:orange,thickness:1.25pt,dash:"dashed"))
 content((x,4.2),anchor:"west",text(fill:blue)[Mean absolute gap: 0.5227])
 content((x+7.3,4.2),anchor:"west",text(fill:orange)[Root mean square: 0.5887])
 content((.4,2.2),angle:90deg,[$abs(e_q)$])
 content((8, - .2),[Forecast $q$; bucket width is $N_q/11$])
 content((8, - .8),[Area = ECE. Every height is nonnegative; no bucket signs cancel.])
})

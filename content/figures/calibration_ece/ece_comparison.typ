// Regenerate JSON with node scripts/calibration_ece_comparison.mjs.
// Both traces come from the same model used by the live comparison panel.
#set page(width:auto,height:auto,margin:2mm,fill:white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font:figure-font,size:9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#let data=json("ece_comparison.json")
#let score(v)=str(calc.round(v,digits:4))
#cetz.canvas(length:1cm,{
 import cetz.draw: *
 let blue=rgb("#2864a5")
 let orange=rgb("#a74e17")
 content((0,8.1),anchor:"west",[*Randomness needs feedback*])
 content((0,7.55),anchor:"west",[Same 11 initial records; all new outcomes are 1; seed #data.seed.])
 let (x,y,w,h)=(.65,2,10,4.3)
 for v in (0,.2,.4,.6){
  line((x,y+v/.7*h),(x+w,y+v/.7*h),stroke:.3pt+luma(85%))
  content((x - .2,y+v/.7*h),anchor:"east",[#str(v)])
 }
 for n in (0,250,500,750,1000){content((x+n/1000*w,y - .25),anchor:"north",[#str(n)])}
 content((x+w/2,y - .85),[New rounds after the initial history])
 content((x - 1.05,y+h/2),angle:90deg,[ECE])
 line((x,y),(x+w,y),stroke:.5pt+luma(70%))
 line((x,y+7/12/.7*h),(x+w,y+7/12/.7*h),stroke:(paint:orange,thickness:.5pt,dash:"dotted"))
 content((x+4,y+7/12/.7*h+.25),anchor:"west",text(fill:orange,size:8.5pt)[Fixed limit: $7/12 approx 0.5833$])
 for (key,index,color,dash) in (("fixed",1,orange,"dashed"),("adaptive",2,blue,none)){
  let points=data.series.filter(p=>p.at(0)<=20 or calc.rem(p.at(0),5)==0)
  line(..points.map(p=>(x+p.at(0)/1000*w,y+p.at(index)/.7*h)),stroke:(paint:color,thickness:1.25pt,dash:dash))
  circle((x+w,y+data.at(key).ece/.7*h),radius:.075,fill:color,stroke:none)
  content((x+w+.18,y+data.at(key).ece/.7*h),anchor:"west",text(fill:color)[*#score(data.at(key).ece)*])
 }
 line((x,6.85),(x+.8,6.85),stroke:(paint:orange,thickness:1.25pt,dash:"dashed"))
 content((x+1,6.85),anchor:"west",text(fill:orange)[Fixed lottery])
 line((x+4.4,6.85),(x+5.2,6.85),stroke:1.25pt+blue)
 content((x+5.4,6.85),anchor:"west",text(fill:blue)[History update])

 let (a,b,bw,bh)=(13.1,2,3.5,4.3)
 content((a - .3,6.85),anchor:"west",[*Next draw after 1,000 rounds*])
 for v in (0,.5,1){
  line((a - .3,b+v*bh),(a+bw+.3,b+v*bh),stroke:.3pt+luma(85%))
  content((a - .4,b+v*bh),anchor:"east",[#str(int(v*100))#"%"])
 }
 for (i,q) in (.25,.5,.75,1).enumerate(){
  let px=a+i*bw/3
  for (key,offset,color) in (("fixed", - .11,orange),("adaptive",.11,blue)){
   let prob=data.at(key).distribution.at(int(q*4))
   line((px+offset,b),(px+offset,b+prob*bh),stroke:2.8pt+color)
  }
  content((px,b - .25),anchor:"north",[#str(q)])
 }
 content((a+bw/2,b - .85),[Forecast value])
 content((a+bw+.1,b+data.adaptive.distribution.at(4)*bh+.25),text(fill:blue)[*#str(calc.round(data.adaptive.distribution.at(4)*100,digits:1))#"%"*])
 content((0,.5),anchor:"west",[Same outcomes and uniform draws; each model updates its own historical ECE.])
 content((0,0),anchor:"west",[Seeded illustration. With independent draws and all-one outcomes, fixed ECE tends to $7/12$.])
})

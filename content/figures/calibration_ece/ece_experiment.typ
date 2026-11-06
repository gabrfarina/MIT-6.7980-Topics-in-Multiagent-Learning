// Static states from the browser experiment; same eleven-record worked history.
#set page(width:auto,height:auto,margin:2mm,fill:white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font:figure-font,size:9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#cetz.canvas(length:1cm,{
 import cetz.draw: *
 let blue=rgb("#2864a5")
 let orange=rgb("#a74e17")
 let w=5.4
 let h=2.5
 for (x,stage,low,high,count,score,rms) in ((0,[1. Commit outcome zero],1/3,2/3,11,[0.5227],[0.5887]),(8.4,[2. One possible draw: forecast 0.50],3/8,5/8,12,[0.5208],[0.5783])){
  content((x,7.4),anchor:"west",[*#stage*])
  content((x,6.8),anchor:"west",if count==11 {[Outcome fixed. No observation added yet.]} else {[Observe zero, then update the 0.50 bucket.]})
  let (a,b)=(x+1,3.1)
  for v in (0,.5,1){
   line((a,b+v*h),(a+w,b+v*h),stroke:.3pt+luma(88%))
   content((a - .18,b+v*h),anchor:"east",text(size:8.5pt)[#str(v)])
  }
  for q in (0,.25,.5,.75,1){content((a+q*w,b - .22),anchor:"north",text(size:8.5pt)[#str(q)])}
  line((a,b),(a+w,b),stroke:.6pt)
  for (q,prob,color,lab) in ((.25,low,blue,if count==11 {[$1/3$]} else {[$3/8$]}),(.5,high,orange,if count==11 {[$2/3$]} else {[$5/8$]})){
   line((a+q*w,b),(a+q*w,b+prob*h),stroke:1.6pt+color)
   circle((a+q*w,b+prob*h),radius:.1,fill:color,stroke:none)
   content((a+q*w,b+prob*h+.35),text(fill:color)[#lab])
  }
  content((a+w/2,b - .65),[Forecast $q$])
  content((x+.2,b+h/2),angle:90deg,[Next draw chance])
  content((x,1.7),anchor:"west",[Recorded rounds: *#count*])
  content((x,1.13),anchor:"west",text(fill:blue)[ECE: *#score*])
  content((x+3.7,1.13),anchor:"west",text(fill:orange)[Root mean square: *#rms*])
  content((x,.45),anchor:"west",if count==11 {[$q=0.50$: one positive in four rounds.]} else {[$q=0.50$: one positive in five rounds.]})
 }
 content((8, - .25),[The outcome is committed before the draw; only the drawn bucket is updated.])
 content((8, - .85),[The other possible draw is 0.25. Its resulting ECE is 0.4583, not 0.5208.])
})

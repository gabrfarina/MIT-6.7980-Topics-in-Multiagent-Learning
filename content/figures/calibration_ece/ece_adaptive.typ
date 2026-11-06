// Foster-Hart Section V, h=.05, PCG64 seed 20261105, 4000 rounds.
// Nature commits y=1 iff public mean forecast < .65, before the private draw.
// Panel 4 plots sampled checkpoints, not a finite-time theorem bound.
#set page(width:auto,height:auto,margin:2mm,fill:white)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font:figure-font,size:9.5pt)
#show: figure-style
#import "@preview/cetz:0.4.1"
#cetz.canvas(length:1cm,{
  import cetz.draw: *
  let blue=rgb("#2864a5")
  let orange=rgb("#bd5c1d")
  let w=5.3
  let h=2.5
  let probability_axes(x,y)={
    for v in (0,.5,1){
      line((x,y+v*h),(x+w,y+v*h),stroke:.25pt+luma(88%))
      content((x - .15,y+v*h),anchor:"east",text(size:8.5pt)[#str(v)])
    }
    for v in (0,.25,.5,.75,1){content((x+v*w,y - .2),anchor:"north",text(size:8.5pt)[#str(v)])}
    line((x,y),(x+w,y),stroke:.6pt)
    line((x,y),(x,y+h),stroke:.6pt)
    content((x+w/2,y - .65),[Forecast $q$])
    content((x - .7,y+h/2),angle:90deg,[Next-draw chance])
  }
  let heading(x,y,t)={content((x+.1,y+5.25),anchor:"north-west",block(width:7.4cm)[*#t*])}
  let footer(x,y,t)={content((x+.1,y+.35),anchor:"north-west",block(width:7.4cm)[#t])}
  let (x,y)=(0,6.4)
  heading(x,y,[1. Read mean errors from the history])
  let (a,b)=(x+1,y+2.8)
  for v in (-1,0,1){
    line((a,b+v*1.25),(a+w,b+v*1.25),stroke:.3pt+luma(85%))
    content((a - .18,b+v*1.25),anchor:"east",str(v))
  }
  line((a,b - 1.25),(a,b+1.25),stroke:.6pt)
  for (q,e) in ((0,1),(.25,.5),(.5, - .25),(.75, - .75),(1,-1)){
    circle((a+q*w,b+e*1.25),radius:.075,fill:luma(70%),stroke:none)
    content((a+q*w,y+1.22),text(size:8.5pt)[#str(q)])
  }
  line((a+.25*w,b+.5*1.25),(a+.5*w,b - .25*1.25),stroke:1pt+blue)
  circle((a+.25*w,b+.5*1.25),radius:.11,fill:blue,stroke:none)
  circle((a+.5*w,b - .25*1.25),radius:.11,fill:orange,stroke:none)
  content((a+.25*w,b+.5*1.25+.34),text(fill:blue)[$+0.5$])
  content((a+.5*w+.2,b - .25*1.25),anchor:"west",text(fill:orange)[$-0.25$])
  content((a+w/2,y+.92),[Forecast $q$])
  content((a - .72,b),angle:90deg,[Mean error $e_q$])
  footer(x,y,[The 0.25 bucket underpredicts; the adjacent 0.50 bucket overpredicts.])
  let (x,y)=(8.25,6.4)
  heading(x,y,[2. Balance errors in the next lottery])
  let (a,b)=(x+1,y+1.5)
  probability_axes(a,b)
  for(q,p,color,label)in((.25,1/3,blue,[$1/3$]),(.5,2/3,orange,[$2/3$])){
    line((a+q*w,b),(a+q*w,b+p*h),stroke:1.6pt+color)
    circle((a+q*w,b+p*h),radius:.1,fill:color,stroke:none)
    content((a+q*w,b+p*h+.35),text(fill:color)[#label])
  }
  footer(x,y,[$(1/3)(0.5)+(2/3)(-0.25)=0$.
    These are next-draw weights, not ECE's historical weights.])
  let (x,y)=(0,0)
  heading(x,y,[3. Observe zero at 0.50, then recompute])
  let (a,b)=(x+1,y+1.5)
  probability_axes(a,b)
  for(q,old,p,color,label)in((.25,1/3,3/8,blue,[$3/8$]),(.5,2/3,5/8,orange,[$5/8$])){
    line((a+q*w+.13,b),(a+q*w+.13,b+old*h),stroke:(paint:luma(65%),thickness:.8pt,dash:"dashed"))
    line((a+q*w,b),(a+q*w,b+p*h),stroke:1.6pt+color)
    circle((a+q*w,b+p*h),radius:.1,fill:color,stroke:none)
    content((a+q*w,b+p*h+.35),text(fill:color)[#label])
  }
  footer(x,y,[The high bucket changes from $1/4-0.5=-0.25$ to $1/5-0.5=-0.3$. More mass moves left.])
  let (x,y)=(8.25,0)
  heading(x,y,[4. Repeat the rule on a finer grid])
  let (a,b)=(x+1,y+1.5)
  for v in (0,.5,1){
    line((a,b+v*h),(a+w,b+v*h),stroke:.25pt+luma(88%))
    content((a - .17,b+v*h),anchor:"east",str(v))
  }
  for t in (1,10,100,1000,4000){
    let xx=a+w*calc.ln(t)/calc.ln(4000)
    content((xx,b - .2),anchor:"north",text(size:8pt)[#t])
  }
  line((a,b),(a+w,b),stroke:.6pt)
  line((a,b),(a,b+h),stroke:.6pt)
  let checkpoints=((1, 0.5), (2, 0.525), (3, 0.5), (4, 0.525), (5, 0.5), (6, 0.525), (7, 0.542857143), (8, 0.5625), (9, 0.577777778), (10, 0.595), (11, 0.609090909), (12, 0.625), (13, 0.638461538), (14, 0.653571429), (15, 0.666666667), (16, 0.68125), (17, 0.694117647), (18, 0.708333333), (19, 0.721052632), (20, 0.735), (21, 0.747619048), (22, 0.697727273), (23, 0.684782609), (24, 0.645833333), (25, 0.642), (26, 0.632692308), (27, 0.596296296), (28, 0.589285714), (29, 0.563793103), (30, 0.56), (31, 0.55483871), (33, 0.509090909), (36, 0.468055556), (39, 0.433333333), (42, 0.403571429), (45, 0.384444444), (48, 0.359375), (52, 0.324038462), (56, 0.300892857), (61, 0.273770492), (66, 0.256818182), (71, 0.241549296), (76, 0.226315789), (83, 0.209036145), (89, 0.198314607), (96, 0.179166667), (104, 0.167307692), (112, 0.157142857), (121, 0.144214876), (130, 0.133076923), (141, 0.123758865), (152, 0.115789474), (164, 0.106097561), (177, 0.0974576271), (191, 0.0897905759), (206, 0.0859223301), (222, 0.0804054054), (240, 0.073125), (258, 0.0684108527), (279, 0.0641577061), (301, 0.0588039867), (325, 0.0547692308), (350, 0.052), (378, 0.0484126984), (408, 0.0460784314), (440, 0.0422727273), (475, 0.0386315789), (513, 0.0355750487), (553, 0.0330018083), (597, 0.031239531), (644, 0.0282608696), (695, 0.0264028777), (750, 0.0242666667), (809, 0.0228059333), (873, 0.0209049255), (942, 0.0195329087), (1017, 0.018387414), (1097, 0.0170464904), (1184, 0.0160050676), (1278, 0.0149061033), (1379, 0.0135605511), (1487, 0.0127101547), (1605, 0.011588785), (1732, 0.011056582), (1869, 0.0102728732), (2017, 0.00927119484), (2176, 0.00861672794), (2348, 0.00790034072), (2534, 0.00735990529), (2734, 0.0070226774), (2950, 0.0066440678), (3184, 0.00603015075), (3435, 0.00554585153), (3707, 0.0053142703), (4000, 0.0050375))
  line(..checkpoints.map(p=>(a+w*calc.ln(p.at(0))/calc.ln(4000),b+h*p.at(1))),stroke:1pt+blue)
  circle((a+w,b+.0050375*h),radius:.075,fill:blue,stroke:none)
  content((a+w - .15,b+.44),anchor:"east",text(fill:blue)[0.0050])
  content((a+w/2,b - .65),[Round $t$ (log scale)])
  content((a - .7,b+h/2),angle:90deg,[Recorded ECE])
  footer(x,y,[One seeded run, 4,000 rounds, spacing 0.05. ECE need not fall on every round.])
})

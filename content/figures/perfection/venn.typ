#set page(width: auto, height: auto, margin: 0mm, fill: none)
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 10pt)
#show: figure-style
#import "@preview/cetz:0.3.4"

#cetz.canvas(length: 1.2cm, {
    import cetz.draw: *
    let col = blue.darken(20%) // luma(40%)

    rect((0, 0), (8, 4), name: "NASH", radius: 2mm, stroke: none, fill: col.transparentize(80%))
    rect((.5, .75), (5.5, 3.5), name: "UNE", radius: 2mm, stroke: none, fill: col.transparentize(80%))
    rect((1, .25), (7.5, 3), name: "SRE", radius: 2mm, stroke: none, fill: col.transparentize(80%))
    rect((1.3, 1.0), (4.8, 2.5), name: "QPE", radius: 2mm, stroke: none, fill: col.transparentize(80%))
    rect((2, .5), (6.75, 2.0), name: "EFPE", radius: 2mm, stroke: none, fill: col.transparentize(80%))

    content("NASH.north", padding: (x: 1mm), name: "NASHlbl")[Nash equilibrium]
    content("UNE.north", padding: (x: 1mm), name: "UNElbl")[Normal-form perfect]
    content("SRE.north", padding: (x: 1mm), name: "SRElbl")[Sequential eq.]
    content("QPE.north", padding: (x: 1mm), name: "QPElbl")[QPE]
    content("EFPE.north", padding: (x: 1mm), name: "EFPElbl")[EFPE]

    let draw-outline(lbl) = {
      get-ctx(ctx => {
        let (_, st, w, s, e, en) = cetz.coordinate.resolve(
          ctx,
          lbl + "lbl.east",
          lbl + ".east",
          lbl + ".south",
          lbl + ".west",
          lbl + "lbl.west",
        )
        set-style(stroke: col.darken(40%).transparentize(50%))
        line(st, (w.at(0) - .2, st.at(1)))
        arc((w.at(0), st.at(1) - .2), start: 0deg, stop: 90deg, radius: .2)
        line((w.at(0), st.at(1) - .2), (w.at(0), s.at(1) + .2))
        arc((w.at(0) - .2, s.at(1)), start: -90deg, stop: 0deg, radius: .2)
        line((w.at(0) - .2, s.at(1)), (e.at(0) + .2, s.at(1)))
        arc((e.at(0), s.at(1) + .2), start: 180deg, stop: 270deg, radius: .2)
        line((e.at(0), s.at(1) + .2), (e.at(0), en.at(1) - .2))
        arc((e.at(0) + .2, en.at(1)), start: 90deg, stop: 180deg, radius: .2)
        line((e.at(0) + .2, en.at(1)), en)
      })
    }

    draw-outline("NASH")
    draw-outline("UNE")
    draw-outline("SRE")
    draw-outline("QPE")
    draw-outline("EFPE")
  })

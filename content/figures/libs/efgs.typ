#import "@preview/cetz:0.3.4"
#import "../../meta/typography.typ": course-sans

#let _num-slash = key => {
  key
    .clusters()
    .map(c => if c == "/" {
      1
    } else {
      0
    })
    .sum()
}
#let _num-children(key, nodes) = {
  let ans = 0

  for (key2, _) in nodes {
    if key2.starts-with(key) and key2 != key {
      ans += 1
    }
  }
  ans
}

#let _kuhn_nodes = (
  "/": (822, 87),
  "/JK": (163, 241),
  "/QK": (426, 253),
  "/QJ": (690, 253),
  "/KJ": (955, 253),
  "/KQ": (1216, 253),
  "/JQ": (1482, 241),
  "/JK/chk": (90, 397),
  "/JK/bet": (236, 420),
  "/QK/chk": (354, 397),
  "/QK/bet": (500, 420),
  "/QJ/chk": (618, 397),
  "/QJ/bet": (764, 420),
  "/KJ/chk": (882, 397),
  "/KJ/bet": (1028, 420),
  "/KQ/chk": (1146, 397),
  "/KQ/bet": (1292, 420),
  "/JQ/chk": (1410, 397),
  "/JQ/bet": (1556, 420),
  "/JK/chk/chk": (51, 588),
  "/JK/chk/bet": (132, 610),
  "/JK/bet/fold": (210, 588),
  "/JK/bet/call": (264, 588),
  "/QK/chk/chk": (318, 588),
  "/QK/chk/bet": (393, 610),
  "/QK/bet/fold": (477, 588),
  "/QK/bet/call": (531, 588),
  "/QJ/chk/chk": (585, 588),
  "/QJ/chk/bet": (656, 610),
  "/QJ/bet/fold": (744, 588),
  "/QJ/bet/call": (798, 588),
  "/KJ/chk/chk": (852, 588),
  "/KJ/chk/bet": (922, 610),
  "/KJ/bet/fold": (1011, 588),
  "/KJ/bet/call": (1065, 588),
  "/KQ/chk/chk": (1119, 588),
  "/KQ/chk/bet": (1183, 610),
  "/KQ/bet/fold": (1278, 588),
  "/KQ/bet/call": (1332, 588),
  "/JQ/chk/chk": (1386, 588),
  "/JQ/chk/bet": (1447, 610),
  "/JQ/bet/fold": (1545, 588),
  "/JQ/bet/call": (1599, 588),
  "/JK/chk/bet/fold": (105, 753),
  "/JK/chk/bet/call": (159, 753),
  "/QK/chk/bet/fold": (367, 753),
  "/QK/chk/bet/call": (420, 753),
  "/QJ/chk/bet/fold": (631, 753),
  "/QJ/chk/bet/call": (684, 753),
  "/KJ/chk/bet/fold": (894, 753),
  "/KJ/chk/bet/call": (946, 753),
  "/KQ/chk/bet/fold": (1158, 753),
  "/KQ/chk/bet/call": (1209, 753),
  "/JQ/chk/bet/fold": (1423, 753),
  "/JQ/chk/bet/call": (1474, 753),
)
#let _kuhn_payoff = key => {
  let win = if key.starts-with("/J") or key.starts-with("/QK") {
    -1
  } else {
    1
  }
  if key.ends-with("call") {
    win *= 2
  }
  if win > 0 {
    win = $+#win$
  } else {
    win = $#win$
  }
  if key.ends-with("fold") {
    let num_slash = _num-slash(key)
    if num_slash == 3 {
      $+1$
    } else {
      $-1$
    }
  } else {
    win
  }
}

#let efg-tree(
  nodes: none,
  payoff: none,
  root-is-chance: true,
  action-name: it => it,
  highlight-edges: (),
  sx: 0.25pt,
  sy: 0.25pt,
  draft: false,
  action-labels: true,
  infoset-labels: true,
  payoffs: true,
  infoset-thickness: 4.0mm,
  ..infosets,
) = [
  #set text(8pt)
  #cetz.canvas({
    import cetz.draw: *

    set-style(stroke: .22mm)
    let map-pos = ((x, y)) => (x * sx, -y * sy)

    let outlined-content(pos, body) = {
      if not draft {
        for i in range(36) {
          let x = (calc.rem(i, 6) - 3) * .1mm
          let y = (calc.floor(i / 6) - 3) * .1mm
          content((pos.at(0) + x, pos.at(1) + y))[#text(white, body)]
        }
      }
      content(pos, body)
    }
    let parent-action(key) = {
      let parent = key
      let action = ""
      while parent.last() != "/" {
        parent = parent.slice(0, -1)
      }
      action = key.slice(parent.len())
      parent = parent.slice(0, -1)
      if parent == "" {
        parent = "/"
      }
      (parent, action)
    }
    let infoset(inodes, bend: 0mm, name: none, right: false) = {
      if inodes.len() > 1 {
        for i in range(inodes.len() - 1) {
          let a = inodes.at(i)
          let b = inodes.at(i + 1)
          let p = map-pos(nodes.at(a))
          let q = map-pos(nodes.at(b))
          let c = (p.at(0) + q.at(0)) / 2
          let d = (p.at(1) + q.at(1)) / 2
          let e = (c, d + bend)
          bezier(p, q, e, stroke: (thickness: infoset-thickness + .5mm, paint: blue.lighten(30%), cap: "round"))
        }
        for i in range(inodes.len() - 1) {
          let a = inodes.at(i)
          let b = inodes.at(i + 1)
          let p = map-pos(nodes.at(a))
          let q = map-pos(nodes.at(b))
          let c = (p.at(0) + q.at(0)) / 2
          let d = (p.at(1) + q.at(1)) / 2
          let e = (c, d + bend)
          bezier(p, q, e, stroke: (thickness: infoset-thickness, paint: blue.lighten(80%), cap: "round"))
          // circle(e, radius: 1mm, fill: white)
          // circle(f, radius: 1mm, fill: white)
        }
      } else {
        let p = map-pos(nodes.at(inodes.at(0)))
        circle(p, radius: infoset-thickness / 2 + .25mm, stroke: none, fill: blue.lighten(30%))
        circle(p, radius: infoset-thickness / 2, stroke: none, fill: blue.lighten(80%))
      }
      if name != none and infoset-labels {
        let p = if right {
          let p = map-pos(nodes.at(inodes.at(-1)))
          (p.at(0) + 3.8mm, p.at(1) + .5mm)
        } else {
          let p = map-pos(nodes.at(inodes.at(0)))
          (p.at(0) - 3.8mm, p.at(1) + .5mm)
        }
        content(p)[#course-sans(fill: blue)[#name]]
      }
    }
    for info in infosets.pos() {
      infoset(info.nodes, bend: info.bend, name: info.name, right: info.at("right", default: false))
    }

    // Make white background of arrows
    for (key, pos) in nodes {
      if key != "/" {
        let (parent, _) = parent-action(key)
        let a = map-pos(nodes.at(parent))
        let b = map-pos(pos)
        line(a, (a: b, b: a, number: .295), stroke: 1.5mm + white)
      }
    }
    for (key, pos) in nodes {
      if key != "/" {
        let (parent, action) = parent-action(key)
        let a = map-pos(nodes.at(parent))
        let b = map-pos(pos)
        let c = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
        let show-label = parent == "/" or action-labels

        let lw = (
          thickness: .3mm,
          paint: if parent == "/" {
            luma(0%)
          } else {
            black
          },
          dash: if parent == "/" {
            "solid"
          } else {
            "solid"
          },
        )
        if key in highlight-edges {
          lw.thickness = 1.2mm
        }

        if show-label {
          line(a, (a: c, b: a, number: .2), stroke: lw)
          line(
            (a: c, b: b, number: .2),
            (a: b, b: a, number: .1),
            mark: (end: "stealth", scale: .8, fill: black, stroke: .4mm),
            stroke: lw,
          )
        } else {
          line(a, (a: b, b: a, number: .1), mark: (end: "stealth", scale: .8, fill: black, stroke: .1mm), stroke: lw)
        }
        if action == "fold" {
          c.at(0) -= 1.5mm
          // c.at(1) -= 1mm
        } else if action == "chk" {
          c.at(0) -= 1mm
          // c.at(1) += .5mm
        } else if action == "call" {
          c.at(0) += 1.5mm
        } else if action == "bet" {
          c.at(0) += 1mm
        }
        if show-label {
          outlined-content(c)[#course-sans(action-name(action))]
        }
      }
    }

    for (key, pos) in nodes {
      let num_slash = _num-slash(key)
      if key == "/" and root-is-chance {
        let p = map-pos(pos)
        circle(p, radius: 1.5mm, fill: white)
        line((p.at(0) - 1mm, p.at(1) - 1mm), (p.at(0) + 1mm, p.at(1) + 1mm))
        line((p.at(0) - 1mm, p.at(1) + 1mm), (p.at(0) + 1mm, p.at(1) - 1mm))
      } else if _num-children(key, nodes) == 0 {
        let p = map-pos(pos)
        rect(
          (p.at(0) - .8mm, p.at(1) - .8mm),
          (p.at(0) + .8mm, p.at(1) + .8mm),
          fill: white,
        )
      } else if calc.rem(num_slash, 2) == int(root-is-chance) or (key == "/" and not root-is-chance) {
        circle(map-pos(pos), radius: .9mm, fill: black)
      } else {
        circle(map-pos(pos), radius: 1.0mm, fill: white)
      }
    }

    if payoffs {
      for (key, pos) in nodes {
        let p = map-pos(pos)
        p = (p.at(0), p.at(1) - 3mm)
        let num_children = _num-children(key, nodes)
        if num_children == 0 {
          let win = payoff(key)

          outlined-content(
            p,
            text(7pt, win),
          )
        }
      }
    }
  })
]

#let kuhn-tree = efg-tree.with(nodes: _kuhn_nodes, payoff: _kuhn_payoff)

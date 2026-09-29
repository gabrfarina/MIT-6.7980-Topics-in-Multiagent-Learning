#import "../../meta/notation.typ": va, vb, vx, vy
#import "../../meta/notation.typ": vg, vm, vr, vz
#import "../../meta/notation.typ": cX, cY, cR, html-argmax as argmax
#import "../../meta/notation.typ": ip
#set page(width: auto, height: auto, fill: none, margin: (left: 1mm, right: 0mm, y: .5mm))
#import "../libs/typography.typ": figure-font, figure-style
#set text(font: figure-font, size: 9pt)
#show: figure-style
#import "../../meta/dyns.typ": dynplot, entropy-prox, euc-prox
#import "@preview/cetz:0.4.1"
#import "@preview/cetz-plot:0.1.2"

#let darkblue = blue.darken(20%)

#table(
  columns: (auto, auto, auto),
  align: (horizon + left, horizon + center, horizon + center),
  inset: (y: 1.8mm, x: 1.0mm),
  fill: (j, i) => if i >= 0 and j == 2 {
    blue.lighten(95%)
  } else {
    none
  },
  stroke: (
    j,
    i,
  ) => (
    top: (
      if i == 0 {
        black + .4mm
      } else {
        none
      }
    ),
    bottom: (
      if i == 0 or i == 2 {
        black + .4mm
      } else {
        gray + .2mm
      }
    ),
    left: (
      if j > 0 {
        gray + .2mm
      }
    ),
    right: (
      if j > 0 and j < 2 {
        gray + .2mm
      }
    ),
  ),
  table.header()[][*Non-predictive version*][*Predictive version*],
  [FTRL],
  $
    vx^((t+1)) := argmax_(vx in cal(X)) {ip(sum_(tau = 1)^t vg^((tau)), vx) - 1 / eta psi(vx)}
  $,
  $
    vx^((t+1)) := argmax_(vx in cal(X)) { ip(#text(darkblue, $vm^((t+1))$) + sum_(tau = 1)^t vg^((tau)), vx) - 1 / eta psi(vx) }
  $,

  [OMD],
  $
    vx^((t+1)) := argmax_(vx in cal(X)) {ip(vg^((t)), vx) - 1 / eta upright("D")_psi (vx || vx^((t)))}
  $,
  [
    #align(left)[#sym.circle.filled *Non-reflected version:*]
    $
      vz^((t+1)) &:= argmax_(vz in cal(X)) {ip(vg^((t)), vz) - 1 / eta upright("D")_psi (vz || vz^((t)))} \
      vx^((t+1)) &:= argmax_(vx in cal(X)) { ip(#text(darkblue, $vm^((t+1))$), vx) - 1 / eta upright("D")_psi (vx || vz^((t+1))) }
    $

    #align(left)[#sym.circle.filled *Reflected version:*]
    $
      vx^((t+1)) := argmax_(vx in cal(X)) { ip(vg^((t)) + #text(darkblue)[$vm^((t+1)) - vm^((t))$], vx) - 1 / eta upright("D")_psi (vx || vx^((t))) }
    $],
)

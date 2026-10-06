// Course-wide mathematical notation. Both note styles re-export this file.
// v* denotes bold vectors, c* calligraphic sets, and mat* upright bold matrices.
// HTML encodings implement the same conventions as the native PDF forms.
#import "typography.typ": course-sans
#let sf = course-sans
#let upsans = it => $upright(sans(#it))$
#let spade = sym.suit.spade

// Number systems and standard operators.
#let eps = math.epsilon.alt
#let BB = $𝔹$
#let CC = $ℂ$
#let NN = $ℕ$
#let QQ = $ℚ$
#let RR = $ℝ$
#let EE = math.op($𝔼$, limits: true)
#let cK = $cal(K)$
#let cS = $cal(S)$
#let PPAD = text(font: "New Computer Modern", "PPAD")
#let NP = text(font: "New Computer Modern", "NP")
#let coNP = text(font: "New Computer Modern", "co-NP")
#let P = text(font: "New Computer Modern", "P")
#let argmin = math.op("arg min", limits: true)
#let argmax = math.op("arg max", limits: true)
#let ip(a, b) = $lr(chevron.l #a, #b chevron.r)$
#let div(a, b, dgf: $phi$) = $op("D")_#dgf (#a mid(||) #b)$
#let divt(a, b) = $op("D")_(phi_t) (#a mid(||) #b)$
#let dom = math.op("dom")
#let diag = math.op("diag")
#let cone = math.op("cone")
#let span = math.op("span")
#let colspan = math.op("colspan")
#let qquad = $quad quad$

// Vectors, matrices, and calligraphic sets (native Typst forms).
#let bb = math.bb
#let va = $bold(a)$
#let vb = $bold(b)$
#let vg = $bold(g)$
#let vm = $bold(m)$
#let vr = $bold(r)$
#let vq = $bold(q)$
#let vs = $bold(s)$
#let vu = $bold(u)$
#let vx = $bold(x)$
#let vy = $bold(y)$
#let vz = $bold(z)$
#let vp = $bold(p)$
#let vc = $bold(c)$
#let ve = $bold(e)$
#let vf = $bold(f)$
#let vh = $bold(h)$
#let vv = $bold(v)$
#let vw = $bold(w)$
#let vell = $bold(ell)$
#let vxi = $bold(xi)$
#let vtheta = $bold(theta)$
#let vphi = $bold(phi)$
#let vmu = $bold(mu)$
#let vnu = $bold(nu)$
#let vlambda = $bold(lambda)$
#let vrho = $bold(rho)$
#let vpi = $bold(pi)$
#let vU = $bold(U)$
#let vV = $bold(V)$
#let vW = $bold(W)$
#let vA = $bold(A)$
#let vR = $bold(R)$
#let vone = $bold(1)$
#let matA = $upright(bold(A))$
#let matI = $upright(bold(I))$
#let matM = $upright(bold(M))$
#let matK = $upright(bold(K))$
#let matU = $upright(bold(U))$
#let cC = $cal(C)$
#let cH = $cal(H)$
#let cU = $cal(U)$
#let cA = $cal(A)$
#let cX = $cal(X)$
#let cY = $cal(Y)$
#let grad = $nabla$
#let conv = math.op("conv")
#let cG = $cal(G)$
#let cR = $cal(R)$

// Decorated vector and matrix notation.
#let xhat = $hat(vx)$
#let yhat = $hat(vy)$
#let mU = $matU_1$

// Symbols used by the calibration comparison diagram.
#let fH = cH
#let fPhi = $Phi$
#let fU = cU
#let fX = cX

// Additional mathematical constructions.
#let dif = $d$
#let nor(pt, domain: $Omega$) = $𝓝_(domain)(pt)$
#let _html-math-undisplay(body) = {
  if type(body) == content and body.func() == math.equation and body.has("body") {
    body.body
  } else {
    body
  }
}
#let opt(dir, var, obj, ..constraints) = {
  let data = (($limits(dir)_(var)$, $&$ + _html-math-undisplay(obj)),)
  for (i, cntnt) in constraints.pos().enumerate(start: 0) {
    if i == 0 {
      data.push(("s.t.", $&$ + _html-math-undisplay(cntnt)))
    } else {
      data.push(("", $&$ + _html-math-undisplay(cntnt)))
    }
  }
  math.mat(delim: none, ..data)
}
#let nablat = math.op($tilde(nabla)#h(-1mm)$)
#let circled(body) = box(
  baseline: .6mm,
  circle(
    radius: 1.6mm,
    stroke: .15mm + luma(50%),
    inset: .3mm,
    body,
  ),
)

// HTML math encodings preserve font information through repr() and KaTeX.
#let _notation-html-math-mode = sys.inputs.at("html-math", default: "svg")
// Explicit Unicode alphabets retain math styling in repr(), which otherwise
// omits the style properties of Typst's styled(child: ..., ..) wrapper.
#let _html-latin-base = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".clusters()
#let _html-latin-alphabets = (
  "cal": "𝒜ℬ𝒞𝒟ℰℱ𝒢ℋℐ𝒥𝒦ℒℳ𝒩𝒪𝒫𝒬ℛ𝒮𝒯𝒰𝒱𝒲𝒳𝒴𝒵𝒶𝒷𝒸𝒹ℯ𝒻ℊ𝒽𝒾𝒿𝓀𝓁𝓂𝓃ℴ𝓅𝓆𝓇𝓈𝓉𝓊𝓋𝓌𝓍𝓎𝓏0123456789".clusters(),
  "cal-bold": "𝓐𝓑𝓒𝓓𝓔𝓕𝓖𝓗𝓘𝓙𝓚𝓛𝓜𝓝𝓞𝓟𝓠𝓡𝓢𝓣𝓤𝓥𝓦𝓧𝓨𝓩𝓪𝓫𝓬𝓭𝓮𝓯𝓰𝓱𝓲𝓳𝓴𝓵𝓶𝓷𝓸𝓹𝓺𝓻𝓼𝓽𝓾𝓿𝔀𝔁𝔂𝔃0123456789".clusters(),
  "bb": "𝔸𝔹ℂ𝔻𝔼𝔽𝔾ℍ𝕀𝕁𝕂𝕃𝕄ℕ𝕆ℙℚℝ𝕊𝕋𝕌𝕍𝕎𝕏𝕐ℤ𝕒𝕓𝕔𝕕𝕖𝕗𝕘𝕙𝕚𝕛𝕜𝕝𝕞𝕟𝕠𝕡𝕢𝕣𝕤𝕥𝕦𝕧𝕨𝕩𝕪𝕫𝟘𝟙𝟚𝟛𝟜𝟝𝟞𝟟𝟠𝟡".clusters(),
  "bold": "𝐀𝐁𝐂𝐃𝐄𝐅𝐆𝐇𝐈𝐉𝐊𝐋𝐌𝐍𝐎𝐏𝐐𝐑𝐒𝐓𝐔𝐕𝐖𝐗𝐘𝐙𝐚𝐛𝐜𝐝𝐞𝐟𝐠𝐡𝐢𝐣𝐤𝐥𝐦𝐧𝐨𝐩𝐪𝐫𝐬𝐭𝐮𝐯𝐰𝐱𝐲𝐳𝟎𝟏𝟐𝟑𝟒𝟓𝟔𝟕𝟖𝟗".clusters(),
  "bold-italic": "𝑨𝑩𝑪𝑫𝑬𝑭𝑮𝑯𝑰𝑱𝑲𝑳𝑴𝑵𝑶𝑷𝑸𝑹𝑺𝑻𝑼𝑽𝑾𝑿𝒀𝒁𝒂𝒃𝒄𝒅𝒆𝒇𝒈𝒉𝒊𝒋𝒌𝒍𝒎𝒏𝒐𝒑𝒒𝒓𝒔𝒕𝒖𝒗𝒘𝒙𝒚𝒛0123456789".clusters(),
  "italic": "𝐴𝐵𝐶𝐷𝐸𝐹𝐺𝐻𝐼𝐽𝐾𝐿𝑀𝑁𝑂𝑃𝑄𝑅𝑆𝑇𝑈𝑉𝑊𝑋𝑌𝑍𝑎𝑏𝑐𝑑𝑒𝑓𝑔ℎ𝑖𝑗𝑘𝑙𝑚𝑛𝑜𝑝𝑞𝑟𝑠𝑡𝑢𝑣𝑤𝑥𝑦𝑧0123456789".clusters(),
  "sans": "𝖠𝖡𝖢𝖣𝖤𝖥𝖦𝖧𝖨𝖩𝖪𝖫𝖬𝖭𝖮𝖯𝖰𝖱𝖲𝖳𝖴𝖵𝖶𝖷𝖸𝖹𝖺𝖻𝖼𝖽𝖾𝖿𝗀𝗁𝗂𝗃𝗄𝗅𝗆𝗇𝗈𝗉𝗊𝗋𝗌𝗍𝗎𝗏𝗐𝗑𝗒𝗓𝟢𝟣𝟤𝟥𝟦𝟧𝟨𝟩𝟪𝟫".clusters(),
  "sans-italic": "𝘈𝘉𝘊𝘋𝘌𝘍𝘎𝘏𝘐𝘑𝘒𝘓𝘔𝘕𝘖𝘗𝘘𝘙𝘚𝘛𝘜𝘝𝘞𝘟𝘠𝘡𝘢𝘣𝘤𝘥𝘦𝘧𝘨𝘩𝘪𝘫𝘬𝘭𝘮𝘯𝘰𝘱𝘲𝘳𝘴𝘵𝘶𝘷𝘸𝘹𝘺𝘻0123456789".clusters(),
  "sans-bold": "𝗔𝗕𝗖𝗗𝗘𝗙𝗚𝗛𝗜𝗝𝗞𝗟𝗠𝗡𝗢𝗣𝗤𝗥𝗦𝗧𝗨𝗩𝗪𝗫𝗬𝗭𝗮𝗯𝗰𝗱𝗲𝗳𝗴𝗵𝗶𝗷𝗸𝗹𝗺𝗻𝗼𝗽𝗾𝗿𝘀𝘁𝘂𝘃𝘄𝘅𝘆𝘇𝟬𝟭𝟮𝟯𝟰𝟱𝟲𝟳𝟴𝟵".clusters(),
  "sans-bold-italic": "𝘼𝘽𝘾𝘿𝙀𝙁𝙂𝙃𝙄𝙅𝙆𝙇𝙈𝙉𝙊𝙋𝙌𝙍𝙎𝙏𝙐𝙑𝙒𝙓𝙔𝙕𝙖𝙗𝙘𝙙𝙚𝙛𝙜𝙝𝙞𝙟𝙠𝙡𝙢𝙣𝙤𝙥𝙦𝙧𝙨𝙩𝙪𝙫𝙬𝙭𝙮𝙯0123456789".clusters(),
)
#let _html-symbol = $A$.body.func()
#let _html-alphabet-char(char, requested, text-mode: false) = {
  let index = _html-latin-base.position(c => c == char)
  let previous = if text-mode { "normal" } else { "italic" }
  if index == none {
    for (kind, alphabet) in _html-latin-alphabets {
      let found = alphabet.position(c => c == char)
      if found != none and alphabet.at(found) != _html-latin-base.at(found) {
        index = found
        previous = kind
        break
      }
    }
  }
  if index == none { return _html-symbol(char) }
  let target = requested
  if requested == "cal" and previous.contains("bold") { target = "cal-bold" }
  if requested == "bold" {
    target = if previous.contains("cal") { "cal-bold" }
      else if previous == "bb" { "bb" }
      else if previous.contains("sans") {
        if previous.contains("italic") { "sans-bold-italic" } else { "sans-bold" }
      } else if previous.contains("italic") { "bold-italic" } else { "bold" }
  }
  if requested == "sans" {
    target = if previous.contains("bold") {
      if previous.contains("italic") { "sans-bold-italic" } else { "sans-bold" }
    } else if previous.contains("italic") { "sans-italic" } else { "sans" }
  }
  if requested == "upright" {
    target = if previous.contains("cal") or previous == "bb" { previous }
      else if previous.contains("sans") {
        if previous.contains("bold") { "sans-bold" } else { "sans" }
      } else if previous.contains("bold") { "bold" } else { "normal" }
  }
  if target == "normal" {
    return math.class("normal", math.op(_html-latin-base.at(index), limits: false))
  }
  // Unicode has no italic digits; use the corresponding upright digits.
  if index >= 52 {
    target = if target == "bold-italic" { "bold" }
      else if target == "sans-italic" { "sans" }
      else if target == "sans-bold-italic" { "sans-bold" } else { target }
  }
  _html-symbol(_html-latin-alphabets.at(target).at(index))
}
#let _html-known-alphabet-char(char) = {
  (char in _html-latin-base or _html-latin-alphabets.values().any(alphabet => char in alphabet)
    or char.match(regex("^[ .,:;!?()\\[\\]{}+*/=\\-]$")) != none)
}
#let _html-simple-alphabet(body) = {
  if type(body) == str { return body.clusters().all(_html-known-alphabet-char) }
  if type(body) != content { return false }
  if body.func() == math.equation { return _html-simple-alphabet(body.body) }
  if body.has("children") { return body.children.all(_html-simple-alphabet) }
  if body.has("text") { return type(body.text) == str and body.text.clusters().all(_html-known-alphabet-char) }
  if body.func() == math.attach {
    return body.fields().values().all(value => value == none or type(value) != content or _html-simple-alphabet(value))
  }
  body.func() in ([ ].func(), linebreak, h)
}
#let _html-font-style(style, native, body) = if _notation-html-math-mode == "katex" {
  math.equation(metadata("katex-font:" + style) + _html-math-undisplay(body))
} else {
  native(body)
}
#let _html-alphabet(body, style, native) = {
  if not _html-simple-alphabet(body) { return _html-font-style(style, native, body) }

  if type(body) == str {
    return body.clusters().map(c => _html-alphabet-char(c, style, text-mode: true)).join()
  }
  if type(body) != content { return native(body) }
  if body.func() == math.equation { return _html-alphabet(body.body, style, native) }
  if body.has("children") {
    return body.children.map(c => _html-alphabet(c, style, native)).join()
  }
  if body.has("text") {
    return body.text.clusters().map(c => _html-alphabet-char(c, style, text-mode: body.func() == text)).join()
  }
  if body.func() == math.attach {
    let fields = body.fields()
    let base = fields.remove("base")
    for key in ("t", "b", "tl", "tr", "bl", "br") {
      if fields.at(key, default: none) != none {
        fields.insert(key, _html-alphabet(fields.at(key), style, native))
      }
    }
    return math.attach(_html-alphabet(base, style, native), ..fields)
  }
  // Whitespace and punctuation do not carry an alphabet; preserve native
  // styling for other compound expressions rather than dropping their content.
  if body.func() in ([ ].func(), linebreak, h) { return body }
  native(body)
}
#let _html-cal-symbol(body) = _html-alphabet(body, "cal", math.cal)
#let html-cal = _html-cal-symbol
#let html-bb(body) = _html-alphabet(body, "bb", math.bb)
#let html-bold(body) = _html-alphabet(body, "bold", math.bold)
#let html-sans(body) = _html-alphabet(body, "sans", math.sans)
#let html-italic(body) = _html-alphabet(body, "italic", math.italic)
#let _html-upright-word(body) = {
  if type(body) == str { return body }
  if type(body) != content { return none }
  if body.func() == math.equation { return _html-upright-word(body.body) }
  if body.func() == [ ].func() { return "" }
  if body.has("text") {
    if type(body.text) == str and body.text.match(regex("^[A-Za-z0-9 .,:;!?()\\-]*$")) != none { return body.text }
    return none
  }
  if body.has("children") {
    let parts = body.children.map(_html-upright-word)
    if parts.any(p => p == none) { return none }
    return parts.join()
  }
  none
}
#let html-upright(body) = {
  let word = _html-upright-word(body)
  if word != none { math.class("normal", math.op(word, limits: false)) }
  else { _html-alphabet(body, "upright", math.upright) }
}

#let html-argmin = math.op($arg#h(1mm)min$, limits: true)
#let html-argmax = math.op($arg#h(1mm)max$, limits: true)
#let html-P = [P]
#let html-PPAD = text(font: "Georgia", "PPAD")
#let html-NP = text(font: "Georgia", "NP")
#let html-coNP = text(font: "Georgia", "co-NP")
#let html-span = $op("span")$
#let html-colspan = $op("colspan")$
#let html-div(a, b, dgf: $phi$) = $op("D") _#dgf (#a mid(||) #b)$
#let html-divt(a, b) = $op("D") _(phi_t) (#a mid(||) #b)$
#let html-matA = $𝐀$
#let html-matI = $𝐈$
#let html-matK = $𝐊$
#let html-matM = $𝐌$
#let html-matU = $𝐔$
#let html-va = $#html-bold($a$)$
#let html-vb = $#html-bold($b$)$
#let html-vg = $#html-bold($g$)$
#let html-vm = $#html-bold($m$)$
#let html-vr = $#html-bold($r$)$
#let html-vc = $#html-bold($c$)$
#let html-vp = $#html-bold($p$)$
#let html-vq = $#html-bold($q$)$
#let html-vs = $#html-bold($s$)$
#let html-vu = $#html-bold($u$)$
#let html-vx = $#html-bold($x$)$
#let html-vy = $#html-bold($y$)$
#let html-vz = $#html-bold($z$)$
#let html-ve = $#html-bold($e$)$
#let html-vf = $#html-bold($f$)$
#let html-vh = $#html-bold($h$)$
#let html-vv = $#html-bold($v$)$
#let html-vw = $#html-bold($w$)$
#let html-vell = $#html-bold($ell$)$
#let html-vxi = $#html-bold($xi$)$
#let html-vtheta = $#html-bold($theta$)$
#let html-vphi = $#html-bold($phi$)$
#let html-vmu = $#html-bold($mu$)$
#let html-vnu = $#html-bold($nu$)$
#let html-vlambda = $#html-bold($lambda$)$
#let html-vrho = $#html-bold($rho$)$
#let html-vpi = $#html-bold($pi$)$
#let html-vU = $#html-bold($U$)$
#let html-vV = $#html-bold($V$)$
#let html-vW = $#html-bold($W$)$
#let html-vA = $#html-bold($A$)$
#let html-vR = $#html-bold($R$)$
#let html-vone = $#html-bold($1$)$
#let html-cA = $#html-cal($A$)$
#let html-cC = $#html-cal($C$)$
#let html-cH = $#html-cal($H$)$
#let html-cK = $#html-cal($K$)$
#let html-cS = $#html-cal($S$)$
#let html-cU = $#html-cal($U$)$
#let html-cX = $#html-cal($X$)$
#let html-cY = $#html-cal($Y$)$
#let html-cG = $#html-cal($G$)$
#let html-cR = $#html-cal($R$)$
#let html-xhat = $hat(#html-vx)$
#let html-yhat = $hat(#html-vy)$
#let html-mU = $#html-matU _1$
#let html-upsans = it => $#html-upright(html-sans(it))$

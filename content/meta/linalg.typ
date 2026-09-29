#let mvp(A, v) = {
  let n = A.len()
  assert(v.len() == n)
  let out = ()
  for i in range(n) {
    let res = 0
    for j in range(n) {
      res += A.at(i).at(j) * v.at(j)
    }
    out.push(res)
  }
  out
}

#let invert(M) = {
  let MC = M
  let eye = ()
  let n = M.len()
  for i in range(n) {
    assert(M.at(i).len() == n)

    let row = ()
    for j in range(n) {
      row.push(if i == j {
        1.0
      } else {
        0.0
      })
    }
    eye.push(row)
  }
  for i in range(n) {
    let pivot = MC.at(i).at(i)
    for j in range(n) {
      MC.at(i).at(j) /= pivot
      eye.at(i).at(j) /= pivot
    }

    for j in range(i + 1, n) {
      let ratio = MC.at(j).at(i) / MC.at(i).at(i)
      for k in range(n) {
        MC.at(j).at(k) -= ratio * MC.at(i).at(k)
        eye.at(j).at(k) -= ratio * eye.at(i).at(k)
      }
    }
  }
  for i in range(n) {
    for j in range(i + 1, n) {
      let ratio = MC.at(i).at(j) / MC.at(j).at(j)
      for k in range(n) {
        MC.at(i).at(k) -= ratio * MC.at(j).at(k)
        eye.at(i).at(k) -= ratio * eye.at(j).at(k)
      }
    }
  }

  eye
}

#let transpose(M) = {
  let n = M.len()
  let m = M.at(0).len()
  let out = ()
  for i in range(m) {
    let row = ()
    for j in range(n) {
      row.push(M.at(j).at(i))
    }
    out.push(row)
  }
  out
}

#let vvp(u, v) = {
  let n = u.len()
  assert(v.len() == n)
  let ans = 0
  for i in range(n) {
    ans += u.at(i) * v.at(i)
  }
  ans
}

#let add(u, v) = {
  let n = u.len()
  assert(v.len() == n)
  let out = ()
  for i in range(n) {
    out.push(u.at(i) + v.at(i))
  }
  out
}

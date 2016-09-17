require expect: func

let a = 3
let b = 7
let c = a++ + ++b

expect(a).to.equal(4)
expect(b).to.equal(8)
expect(c).to.equal(11)
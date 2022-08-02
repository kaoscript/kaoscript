require expect: func

var dyn a = 3
var dyn b = 7
var dyn c = a++ + ++b

expect(a).to.equal(4)
expect(b).to.equal(8)
expect(c).to.equal(11)
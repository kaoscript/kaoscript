require expect: func

var t = true
var f = false

expect(f -> f).to.equal(true)
expect(t -> f).to.equal(false)
expect(f -> t).to.equal(true)
expect(t -> t).to.equal(true)

expect(f -> f -> f).to.equal(false)
expect(t -> f -> f).to.equal(true)
expect(f -> t -> f).to.equal(false)
expect(t -> t -> f).to.equal(false)
expect(f -> f -> t).to.equal(true)
expect(t -> f -> t).to.equal(true)
expect(f -> t -> t).to.equal(true)
expect(t -> t -> t).to.equal(true)
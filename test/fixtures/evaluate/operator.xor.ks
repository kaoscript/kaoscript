require expect: func

const t = true
const f = false

expect(f ^^ f).to.equal(false)
expect(t ^^ f).to.equal(true)
expect(f ^^ t).to.equal(true)
expect(t ^^ t).to.equal(false)

expect(f ^^ f ^^ f).to.equal(false)
expect(t ^^ f ^^ f).to.equal(true)
expect(f ^^ t ^^ f).to.equal(true)
expect(t ^^ t ^^ f).to.equal(false)
expect(f ^^ f ^^ t).to.equal(true)
expect(t ^^ f ^^ t).to.equal(false)
expect(f ^^ t ^^ t).to.equal(false)
expect(t ^^ t ^^ t).to.equal(true)
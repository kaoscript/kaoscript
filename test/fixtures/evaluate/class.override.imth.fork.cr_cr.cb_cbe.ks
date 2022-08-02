require expect: func

class Foobar {
	compare(value: Foobar) => 'foobar/foobar'
}

class Quxbaz extends Foobar {
	compare(value: Quxbaz) => 'quxbaz/quxbaz'
}

func compare(a: Foobar, b: Foobar) => a.compare(b)

var f = new Foobar()
var q = new Quxbaz()

expect(compare(f, f)).to.equal('foobar/foobar')
expect(compare(f, q)).to.equal('foobar/foobar')
expect(compare(q, f)).to.equal('foobar/foobar')
expect(compare(q, q)).to.equal('quxbaz/quxbaz')
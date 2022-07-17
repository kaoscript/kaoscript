require expect: func

class Foobar {
	compare(value: Foobar) => 'foobar/foobar'
}

class Quxbaz extends Foobar {
	compare(value: Foobar) => 'quxbaz/foobar'
	compare(value: Quxbaz) => 'quxbaz/quxbaz'
}

func compare(a: Foobar, b: Foobar) => a.compare(b)

const f = new Foobar()
const q = new Quxbaz()

expect(compare(f, f)).to.equal('foobar/foobar')
expect(compare(f, q)).to.equal('foobar/foobar')
expect(compare(q, f)).to.equal('quxbaz/foobar')
expect(compare(q, q)).to.equal('quxbaz/quxbaz')
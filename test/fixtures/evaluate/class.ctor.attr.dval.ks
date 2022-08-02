require expect: func

class Foobar {
	private {
		@parent: Foobar?
		@type: String?
	}
	constructor(@parent, @type = parent?.type())
	type(): @type
}

func foobar(...args?) => new Foobar(...args!!)

var r = foobar(null, 'foobar')

expect(r.type()).to.equal('foobar')

var onlyParent = foobar(r)

expect(onlyParent.type()).to.equal('foobar')

var nullType = foobar(r, null)

expect(nullType.type()).to.equal(null)
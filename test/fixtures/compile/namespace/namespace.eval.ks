require expect: func

namespace NS {
	const foobar = 42

	export *
}

expect(NS is Namespace).to.equal(true)
expect(NS.foobar).to.equal(42)

func foobar(x: Namespace) => 'namespace'
func foobar(x: Number) => 'number'
func foobar(x) => 'any'

expect(foobar(NS)).to.equal('namespace')
expect(foobar(NS.foobar)).to.equal('number')
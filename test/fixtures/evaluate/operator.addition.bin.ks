require expect: func

func s_se(x: String, y: String) => x + y
func s_sne(x: String, y: String?) => x + y
func s_ane(x: String, y?) => x + y
func s_ae(x: String, y) => x + y
func a_ae(x, y) => x + y
func a_ane(x, y?) => x + y

expect(s_se('foo', 'bar')).to.equal('foobar')
expect(s_sne('foo', null)).to.equal('foo')
expect(s_ane('foo', null)).to.equal('foo')
expect(s_ae('foo', 42)).to.equal('foo42')
expect(a_ae('foo', 'bar')).to.equal('foobar')
expect(a_ae('foo', 42)).to.equal('foo42')
expect(a_ae(42, 42)).to.equal(84)
expect(a_ae(42, 'foo')).to.equal('42foo')
expect(a_ane(42, null)).to.equal(null)
expect(() => a_ae(42, true)).to.throw('The elements of a addition must be numbers')
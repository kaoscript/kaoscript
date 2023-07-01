require expect: func

func fn(this) {
	this.foobar = 42

	return () => {
		this.quxbaz = 24

		return this
	}
}

var obj = {}

expect(fn*$(obj)()).to.eql(obj)
expect(obj.foobar).to.eql(42)
expect(obj.quxbaz).to.eql(24)
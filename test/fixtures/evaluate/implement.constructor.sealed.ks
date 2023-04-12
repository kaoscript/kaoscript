require expect: func

extern sealed class Date

#![rules(non-exhaustive)]
impl Date {
	constructor(values: Array) {
		this.setFullYear(...values)
	}
	constructor(value: String) {
		this(value.split('-'))
	}
	constructor(year) {
		this(year, 1, 1)
	}
}

var d2 = Date.new([2000, 1, 1])
expect(d2.getFullYear()).to.equals(2000)
expect(d2.getMonth()).to.equals(1)
expect(d2.getDate()).to.equals(1)

var d3 = Date.new('2000-01-01')
expect(d3.getFullYear()).to.equals(2000)
expect(d3.getMonth()).to.equals(1)
expect(d3.getDate()).to.equals(1)

var d4 = Date.new(2000)
expect(d4.getFullYear()).to.equals(2000)
expect(d4.getMonth()).to.equals(1)
expect(d4.getDate()).to.equals(1)
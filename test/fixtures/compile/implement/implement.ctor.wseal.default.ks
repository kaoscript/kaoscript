extern sealed class Date
extern console

#![rules(non-exhaustive)]
impl Date {
	constructor(values: Array) {
		this.setFullYear(...values)

		console.log(this.getFullYear(), this.getMonth(), this.getDate())
	}
	constructor(value: String) {
		this(value.split('-'))

		console.log(this.getFullYear(), this.getMonth(), this.getDate())
	}
	constructor(year) {
		this(year, 1, 1)

		console.log(this.getFullYear(), this.getMonth(), this.getDate())
	}
}

var d1 = new Date()
var d2 = new Date([2000, 1, 1])
var d3 = new Date('2000-01-01')
var d4 = new Date(2000)

export Date
extern console

require|import '../_/_date.ks'

impl Date {
	static {
		today(): Date => Date.new().midnight()
	}
	midnight(): Date {
		this.setHours(0)
		this.setMinutes(0)
		this.setSeconds(0)
		this.setMilliseconds(0)
		return this
	}
}

console.log(Date.today())
console.log(Date.new().midnight())

export Date
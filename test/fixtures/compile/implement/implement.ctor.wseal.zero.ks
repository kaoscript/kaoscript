extern sealed class Date

impl Date {
	constructor() {
		this.setFullYear(2000, 1, 1)
	}
}

var d = Date.new()

export Date
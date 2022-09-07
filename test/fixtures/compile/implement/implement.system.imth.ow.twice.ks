require|extern system class Date

disclose Date {
	constructor()
	constructor(date: Date)
	constructor(time: Number)
	toString(): String

	internal {
		toISOString(): String
	}
}

impl Date {
	overwrite toString(): String => this.toISOString()
}

impl Date {
	overwrite toString(): String {
		return precursor()
	}
}
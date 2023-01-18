class Foobar {
	private {
		@flag: Boolean
	}
	constructor(@flag = false) {
		this._flag ||= true
	}
}
class Foobar {
	private {
		@flag: Boolean
	}
	constructor(@flag = false) {
		this._flag = this._flag || true
	}
}
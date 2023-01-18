class Foobar {
	private {
		@flag: Boolean
	}
	constructor(@flag = false) {
		@flag ||= true
	}
}
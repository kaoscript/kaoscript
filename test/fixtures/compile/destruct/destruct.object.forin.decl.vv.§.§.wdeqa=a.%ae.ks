class Foobar {
	private {
		@flag: Boolean = false
	}
	foobar() {
		for var { name, flag = @flag } in quxbaz() {
		}
	}
}

func quxbaz() {
}
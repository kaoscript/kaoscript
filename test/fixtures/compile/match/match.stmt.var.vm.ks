func foobar(value) {
	match var mut x = value() {
		1 {
			echo(x)
		}
		else {
			x = 5

			echo(x)
		}
	}
}
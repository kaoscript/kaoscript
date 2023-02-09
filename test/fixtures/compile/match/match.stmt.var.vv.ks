func foobar(value) {
	match var x = value() {
		1 {
			echo(x)
		}
		else {
			echo('bye!')
		}
	}
}
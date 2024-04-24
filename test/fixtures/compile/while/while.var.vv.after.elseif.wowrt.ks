func foobar(test) {
	var dyn data = 42

	if test(0) {
	}
	else if test(1) {
		while #[overwrite] var data ?= quxbaz() {
			echo(data)
		}

		echo(data)
	}

	echo(data)
}

func quxbaz() {

}
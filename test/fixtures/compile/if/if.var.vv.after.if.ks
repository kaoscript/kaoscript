func foobar(test) {
	var dyn data = 42

	if test {
		if var data ?= quxbaz() {
			echo(data)
		}

		echo(data)
	}

	echo(data)
}

func quxbaz() {

}
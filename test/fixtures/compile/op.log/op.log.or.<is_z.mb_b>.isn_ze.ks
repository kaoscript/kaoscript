type Foobar = {
	flag: Boolean
}

func foobar(value) {
	if (value is Foobar && value.flag) || value is not Foobar {
	}
}
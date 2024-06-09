type Data = {
	line: Number
}

impl Data {
	debug(): Void {
		echo(@line)
	}
}

func foobar(data: Data) {
	data.debug()
}
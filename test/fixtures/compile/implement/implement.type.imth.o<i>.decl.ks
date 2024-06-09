type Data = {
	line: Number
}

impl Data {
	debug(): Void {
		var line = @line

		echo(`line: \(line)`)
	}
}
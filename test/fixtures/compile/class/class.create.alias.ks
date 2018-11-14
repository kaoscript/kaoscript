class Writer {
	private {
		_line: class
	}
	constructor(@line)
	newLine(...args) => new @line(...args)
}
class Writer {
	private {
		_line: class
	}
	constructor(@line)
	newLine(...args) => @line.new(...args)
}
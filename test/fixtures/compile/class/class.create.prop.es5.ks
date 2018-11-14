#![format(classes='es5', functions='es5', parameters='es5', spreads='es5')]

class Writer {
	public {
		Line: class
	}
	constructor(@Line)
	newLine(...args) => new this.Line(...args)
}
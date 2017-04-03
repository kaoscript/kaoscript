extern sealed class Function

impl Function {
	enclose(enclosure): Function {
		let f = this
		return (...args) => enclosure(f, ...args)
	}
}
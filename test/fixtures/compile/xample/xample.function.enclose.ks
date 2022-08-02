extern sealed class Function

impl Function {
	enclose(enclosure): Function {
		var dyn f = this
		return (...args) => enclosure(f, ...args)
	}
}
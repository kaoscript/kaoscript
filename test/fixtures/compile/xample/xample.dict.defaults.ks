extern sealed class Dictionary

impl Dictionary {
	static {
		defaults(...args): Dictionary => Dictionary.merge({}, ...args)
		merge(...args) => {}
	}
}

func init(data) {
	return Dictionary.defaults(data, {
		foo: 'bar'
	})
}
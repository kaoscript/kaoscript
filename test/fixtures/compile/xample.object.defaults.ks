extern sealed class Object

impl Object {
	static {
		defaults(...args): Object => Object.merge({}, ...args)
		merge(...args) => {}
	}
}

func init(data) {
	return Object.defaults(data, {
		foo: 'bar'
	})
}
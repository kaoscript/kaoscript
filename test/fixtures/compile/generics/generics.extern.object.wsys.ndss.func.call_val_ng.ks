extern system class Object<V, K> {
	static {
		keys(obj: Object<V, K>): Array<K>
	}
}

func foobar(object: Object) => Object.keys(object)
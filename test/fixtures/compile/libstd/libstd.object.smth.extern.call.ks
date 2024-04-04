#![libstd(off)]

extern system class Object<V is Any?, K> {
	static {
		entries(obj: Object<V, K>): [K, V][]
		keys(obj: Object<V, K>): Array<K>
	}
}

func foobar(value: Object) {
	var keys = Object.keys(value)
}
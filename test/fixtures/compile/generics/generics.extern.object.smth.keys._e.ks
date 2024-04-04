#![libstd(package='npm:@kaoscript/runtime/src/libstd/atomic.ks')]

extern system class Object<V, K> {
	static {
		entries(obj: Object<V, K>): [K, V][]
		keys(obj: Object<V, K>): Array<K>
	}
}

func foobar(values) {
	var keys = Object.keys(values)

	for var key in keys {
		echo(`\(key)`)
	}
}
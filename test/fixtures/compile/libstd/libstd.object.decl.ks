#![libstd(package='.')]

extern system class Object<V, K> {
	static {
		entries(obj: Object<V, K>): [K, V][]
		keys(obj: Object<V, K>): Array<K>
	}
}

export *
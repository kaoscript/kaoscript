#![libstd(package='.')]

extern system class Array<T> {
	length: Number
}

extern system class Object<V, K> {
	static {
		entries(obj: Object<V, K>): [K, V][]
		keys(obj: Object<V, K>): Array<K>
	}
}

impl Object {
	static {
		length(object: Object): Number => Object.keys(object).length
	}
}

export *
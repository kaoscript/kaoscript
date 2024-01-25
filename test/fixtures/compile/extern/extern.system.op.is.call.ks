extern system class Object<V, K> {
	static {
		keys(obj: Object<V, K>): Array<K>
	}
}

func foobar(obj: Object) {
	if obj.clone is Function {
		return obj.clone()
	}
}
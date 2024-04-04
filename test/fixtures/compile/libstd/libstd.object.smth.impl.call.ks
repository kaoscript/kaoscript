#![libstd(off)]

impl Object {
	static foobar(obj: Object) {
	}
}

func foobar(value: Object) {
	Object.foobar(value)
}
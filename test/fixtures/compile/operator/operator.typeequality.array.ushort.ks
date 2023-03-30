struct Foobar {
}

type FoobarArray = Foobar | Foobar[]

func foobar(value: FoobarArray) {
	if value is Array {
	}
}
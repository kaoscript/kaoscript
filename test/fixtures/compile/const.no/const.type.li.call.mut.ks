extern system class Array {
	push(...)
}

type MyArr = const number[]

func foobar(values: MyArr) {
	values.push(4)
}
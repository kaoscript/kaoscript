extern system class Array {
	indexOf(const this, ...): Number
	indexOf(readonly this, ...): Number
}

type MyArr = const number[]

func foobar(values: MyArr) {
	var index = values.indexOf(3)
}
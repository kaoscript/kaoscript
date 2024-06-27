syntime func test(from: Number, to: Number) {
	quote x.length == #w(from)

	for var i from from + 1 to to {
		quote \ || x.length == #w(i)
	}
}

func foobar(x) {
	if test(1, 4) {
	}
}
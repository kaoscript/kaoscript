macro test(@from: Number, @to: Number) {
	macro x.length == #w(from)

	for const i from from + 1 to to {
		macro \ || x.length == #w(i)
	}
}

func foobar(x) {
	if test!(1, 4) {
	}
}
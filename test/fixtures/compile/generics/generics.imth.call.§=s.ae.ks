class Foobar {
	foobar<T is String>(x: T): T {
		return x
	}
}

func foobar(x) {
	var value = Foobar.new()

	echo(`\(value.foobar(x))`)
}
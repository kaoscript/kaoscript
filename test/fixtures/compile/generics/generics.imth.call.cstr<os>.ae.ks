type Named = {
	name: String
}

class Foobar {
	foobar<T is Named>(value: T) {
	}
}

func foobar(arg) {
	var value = Foobar.new()

	value.foobar(arg)
}
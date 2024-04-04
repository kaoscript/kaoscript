type Named = {
	name: String
}

class Foobar {
	foobar<T is Named>(value: T) {
		echo(`\(value.name)`)
	}
}

func foobar(arg: Named) {
	var value = Foobar.new()

	value.foobar(arg)
}
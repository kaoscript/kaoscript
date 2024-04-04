type Named = {
	name: String
}

class Foobar {
	foobar<T is Named>(value: T) {
		echo(`\(value.name)`)
	}
}
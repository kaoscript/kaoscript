type Named = {
	name: String
}

func foobar<T is Named>(value: T) {
	echo(`\(value.name)`)
}

foobar({ name: 'Hello!' })
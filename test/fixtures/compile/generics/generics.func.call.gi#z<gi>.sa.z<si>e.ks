type Named<T> = {
	name: T
	age: Number
}

func foobar<T>(name: T, age: Number): Named<T> {
	return {
		name
		age
	}
}

func quxbaz(name: String, age): Named<String> {
	return foobar(name, age)
}
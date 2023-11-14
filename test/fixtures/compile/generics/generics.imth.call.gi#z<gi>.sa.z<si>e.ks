type Named<T> = {
	name: T
	age: Number
}

class Foobar {
	foobar<T>(name: T, age: Number): Named<T> {
		return {
			name
			age
		}
	}
	quxbaz(name: String, age): Named<String> {
		return @foobar(name, age)
	}
}
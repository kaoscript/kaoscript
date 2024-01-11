extern {
	class ClassA
	class ClassB
}

class Foobar {
	private late {
		@loader: ClassA | ClassB | Null
	}
	foobar() {
		for var value of @loader.load() {
		}
	}
}
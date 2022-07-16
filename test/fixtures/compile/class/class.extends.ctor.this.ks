class ClassA {
}

class ClassB extends ClassA {
	private {
		_x: Number	= 42
	}
	constructor() {
		super()
	}
	constructor(@x) {
		this()
	}
}

class ClassC extends ClassA {
	private {
		_domain: String
		_name: String
	}
	constructor(@name) {
		this(name, 'home')
	}
	constructor(@name, @domain)
}
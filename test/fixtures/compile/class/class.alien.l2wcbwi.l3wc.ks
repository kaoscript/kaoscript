extern sealed class ClassA

class ClassB extends ClassA {
	public {
		foobar: String	= 'foobar'
		quxbaz: Number	= 42
	}
	constructor(@foobar) {
		super()
	}
	constructor(@foobar, @quxbaz) {
		super()
	}
}

class ClassC extends ClassB {
	constructor() {
		super('foobar')
	}
	constructor(@foobar) {
		super(foobar)
	}
	constructor(@foobar, @quxbaz) {
		super(foobar, quxbaz)
	}
}

class ClassD extends ClassC {

}
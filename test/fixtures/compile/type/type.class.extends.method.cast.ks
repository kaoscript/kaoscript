class ClassA {
	foobar() => this
}

class ClassX extends ClassA {
	private {
		@foobar: ClassA
	}
	foobar() => @foobar
	foobar(@foobar) => this
}

class ClassY extends ClassA {
	private {
		@foobar: ClassA
	}
	quxbaz() {
		@foobar = @foobar:ClassX.foobar()
	}
}
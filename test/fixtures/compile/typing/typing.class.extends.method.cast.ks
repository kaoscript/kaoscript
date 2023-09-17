class ClassA {
	foobar() => this
}

class ClassX extends ClassA {
	private {
		@foobar: ClassA	= ClassA.new()
	}
	foobar() => @foobar
	foobar(@foobar) => this
}

class ClassY extends ClassA {
	private {
		@foobar: ClassA	= ClassA.new()
	}
	quxbaz() {
		@foobar = @foobar:ClassX.foobar()
	}
}
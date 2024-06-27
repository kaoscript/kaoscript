syntime func foobar(x) {
	quote #(x)
}

export namespace NS {
	export namespace MD {
		export foobar

		func foo() => foobar('42')
	}

	func foo() => MD.foobar('42')
}

func foo() => foobar('42')
func bar() => NS.MD.foobar('42')
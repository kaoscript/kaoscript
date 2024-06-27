export namespace NS {
	export namespace MD {
		export syntime func foobar(x) {
			quote #(x)
		}

		func foo() => foobar('42')
	}

	func foo() => MD.foobar('42')
}

func foo() => NS.MD.foobar('42')
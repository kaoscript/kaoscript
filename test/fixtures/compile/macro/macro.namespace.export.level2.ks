export namespace NS {
	export namespace MD {
		export macro foobar(@x) {
			macro #(x)
		}

		func foo() => foobar('42')
	}

	func foo() => MD.foobar('42')
}

func foo() => NS.MD.foobar('42')
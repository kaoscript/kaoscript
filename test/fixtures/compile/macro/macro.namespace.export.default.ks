export namespace NS {
	export macro foobar(@x) {
		macro #(x)
	}
}

func foo() => NS.foobar!('42')
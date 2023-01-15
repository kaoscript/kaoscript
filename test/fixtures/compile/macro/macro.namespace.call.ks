namespace NS {
	macro foobar(@x) {
		macro #(x)
	}

	func foo() => foobar('42')
}

export NS
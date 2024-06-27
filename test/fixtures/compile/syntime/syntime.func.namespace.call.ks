namespace NS {
	syntime func foobar(x) {
		quote #(x)
	}

	func foo() => foobar('42')
}

export NS
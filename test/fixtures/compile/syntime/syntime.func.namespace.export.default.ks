export namespace NS {
	export syntime func foobar(x) {
		quote #(x)
	}
}

func foo() => NS.foobar('42')
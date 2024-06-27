syntime func foobar(x) {
	quote #(x)
}

export namespace NS {
	export foobar => qux
}

func foo() => foobar('42')
func qux() => NS.qux('42')
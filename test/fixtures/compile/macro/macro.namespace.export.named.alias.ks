macro foobar(@x) {
	macro #(x)
}

export namespace NS {
	export foobar => qux
}

func foo() => foobar!('42')
func qux() => NS.qux!('42')
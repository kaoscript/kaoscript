macro foobar(@x) {
	macro #(x)
}

export namespace NS {
	export {
		foobar
	}
}

func foo() => foobar('42')
func qux() => NS.foobar('42')
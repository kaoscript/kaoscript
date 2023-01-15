export namespace NS {
	export class Foobar {
		macro foobar(@x) {
			macro #(x)
		}
	}

	func foo() => Foobar.foobar('42')
}

func foo() => NS.Foobar.foobar('42')
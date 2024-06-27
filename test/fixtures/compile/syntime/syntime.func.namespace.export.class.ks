export namespace NS {
	export class Foobar {
		syntime func foobar(x) {
			quote #(x)
		}
	}

	func foo() => Foobar.foobar('42')
}

func foo() => NS.Foobar.foobar('42')
extern sealed class Foobar {

}

impl Foobar {
	foo() {

	}
}

func foobar(): Foobar => new Foobar()

func qux(x: String) {

}

func qux(x: Foobar) {

}

export foobar, qux
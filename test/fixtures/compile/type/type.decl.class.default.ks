extern sealed class Foobar

impl Foobar {
	foobar() {

	}
}

func foo(x: Boolean) {
	var dyn y: Foobar? = null

	y = bar()

	if y != null {
		y.foobar()
	}
}

func bar() {

}
#[rules(non-exhaustive)]
extern class Foobar {
	foobar(): String
}

func foobar(x: Foobar, y: Foobar) {
	if x.foobar() == y.foobar() {

	}
}
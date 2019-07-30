extern class Foobar

#[rules(non-exhaustive)]
disclose Foobar {
	foobar(): String
}

func foobar(x: Foobar, y: Foobar) {
	if x.foobar() == y.foobar() {

	}
}
extern class Foobar

#[rules(non-exhaustive)]
disclose Foobar {
}

func foobar(x: Foobar, y: Foobar) {
	if x.foobar() == y.foobar() {

	}
}
extern class Foobar

disclose Foobar {
	foobar(): String
}

func foobar(x: Foobar, y: Foobar) {
	if x.foobar() == y.foobar() {

	}
}
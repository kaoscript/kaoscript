namespace Foobar {
	export func foobar() => 42
}

impl Foobar {
	quxbaz(foobar = Foobar.foobar()) {
	}
}
class Foobar {
	static get(x: String): Foobar {
		return new Foobar()
	}
}

func foobar(x: Foobar | String = null) {
	if !?x {
		x = Foobar.get('foobar')
	}

	if x is String {
		x = Foobar.get(x)
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}

export Foobar, foobar, quxbaz
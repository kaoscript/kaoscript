class Foobar {
	static get(x: String): Foobar {
		return Foobar.new()
	}
}

func foobar(mut x: Foobar | String | Null = null) {
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
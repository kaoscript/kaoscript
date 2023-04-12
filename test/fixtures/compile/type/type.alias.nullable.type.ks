class Foobar {
	static get(x: String): Foobar {
		return Foobar.new()
	}
}

type FS = Foobar | String

func foobar(mut x: FS? = null) {
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
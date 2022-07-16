class Foobar {
	static get(x: String) {
		return new Foobar()
	}
}

type FS = Foobar | String

func foobar(x: FS = null) {
	// if !?x {
	// 	x = Foobar.get('foobar')
	// }

	if x is String {
		// x = Foobar.get(x)
	}

	quxbaz(x)
}

func quxbaz(x: Foobar) {

}
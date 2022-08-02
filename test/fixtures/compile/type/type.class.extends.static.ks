class Quxbaz {
	static get(): Quxbaz => new Quxbaz()
}

class Foobar extends Quxbaz {
	static get(): Foobar => new Foobar()
}

func foobar(x: Foobar) {

}

var x = Foobar.get()

foobar(x)

export Foobar, Quxbaz
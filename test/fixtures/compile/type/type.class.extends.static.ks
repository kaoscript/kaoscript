class Quxbaz {
	static get(): Quxbaz => Quxbaz.new()
}

class Foobar extends Quxbaz {
	static get(): Foobar => Foobar.new()
}

func foobar(x: Foobar) {

}

var x = Foobar.get()

foobar(x)

export Foobar, Quxbaz
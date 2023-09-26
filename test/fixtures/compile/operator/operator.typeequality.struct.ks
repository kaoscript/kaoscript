struct Foobar {
}

if Foobar is Struct {
}

struct Quxbaz extends Foobar {

}

func foobar(x) {
	if x is Quxbaz {

	}
	else if x is Foobar {

	}
}
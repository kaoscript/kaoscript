import '../_/_function.ks'

func foobar(x: String): Function => () => {
	return x
}

export foobar
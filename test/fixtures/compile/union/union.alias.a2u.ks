type NS = Number | String

func foobar(x: Number | String) {

}

func quxbaz(x: NS) {
	foobar(x)
}
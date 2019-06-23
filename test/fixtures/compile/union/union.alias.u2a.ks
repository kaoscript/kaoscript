type NS = Number | String

func foobar(x: NS) {

}

func quxbaz(x: Number | String) {
	foobar(x)
}
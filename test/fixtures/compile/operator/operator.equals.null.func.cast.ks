func foobar(): String => ''

func quxbaz(mut x: String? = null): String {
	var mut y? = null

	if x == null {
		y = x = foobar() as String
	}

	return x
}
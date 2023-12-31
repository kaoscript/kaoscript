func foobar(): Number | String {
	return 42
}

func quxbaz(x: Number) {
}

quxbaz(foobar():&(Number))
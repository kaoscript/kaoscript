require {
	func quxbaz()
	func corge(x)
}

func foobar(test) {
	corge(
		if test {
			set quxbaz()
				..foobar()
		}
		else {
			set 0
		}
	)
}
func foobar(x) {
	let value
	switch x {
		0, 1 => {
			value = 'binary'
		}
		=> {
			return null
		}
	}

	quxbaz(value)
}

func quxbaz(value) {
}
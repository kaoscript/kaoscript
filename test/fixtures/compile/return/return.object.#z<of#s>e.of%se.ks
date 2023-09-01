type Foobar = { foobar(): String }

func foobar(): Foobar {
	return {
		foobar: func() {
			return ''
		}
	}
}
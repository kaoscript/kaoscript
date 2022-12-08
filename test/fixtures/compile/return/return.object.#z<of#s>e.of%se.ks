type Foobar = { foobar(): String }

func foobar(): Foobar {
	return {
		foobar() {
			return ''
		}
	}
}
type VThunk = (): Void

func foobar(): VThunk {
	return () => {
		echo('hello')
	}
}
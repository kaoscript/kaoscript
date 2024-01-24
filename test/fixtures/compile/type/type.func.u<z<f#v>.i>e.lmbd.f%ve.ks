type VThunk = (): Void

func foobar(): VThunk | Number {
	return () => {
		echo('hello')
	}
}
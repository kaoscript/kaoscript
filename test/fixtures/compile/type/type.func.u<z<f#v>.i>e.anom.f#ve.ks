type VThunk = (): Void

func foobar(): VThunk | Number {
	return func(): Void {
		echo('hello')
	}
}
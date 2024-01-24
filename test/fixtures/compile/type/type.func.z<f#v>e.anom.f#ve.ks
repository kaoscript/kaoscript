type VThunk = (): Void

func foobar(): VThunk {
	return func(): Void {
		echo('hello')
	}
}
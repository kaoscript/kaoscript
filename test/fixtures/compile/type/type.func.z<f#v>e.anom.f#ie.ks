type VThunk = (): Void

func foobar(): VThunk {
	return func(): Number {
		return 0
	}
}
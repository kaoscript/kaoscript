type VThunk = (): Void

func foobar(): VThunk | Number {
	return func(): Number {
		return 0
	}
}
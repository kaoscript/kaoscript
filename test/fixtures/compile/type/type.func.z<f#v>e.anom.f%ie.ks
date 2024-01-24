type VThunk = (): Void

func foobar(): VThunk {
	return func() {
		return 0
	}
}
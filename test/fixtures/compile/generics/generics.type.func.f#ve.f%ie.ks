type Thunk<T> = (): T

func foobar(): Thunk<Void> {
	return () => {
		return 0
	}
}
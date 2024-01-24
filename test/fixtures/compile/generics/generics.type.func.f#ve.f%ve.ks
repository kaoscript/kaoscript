type Thunk<T> = (): T

func foobar(): Thunk<Void> {
	return () => {
		echo('hello')
	}
}
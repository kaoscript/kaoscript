type Event<T> = {
	value: T
}

type Value = { value: String }

func foobar({ value }: Event<Value>) {
}
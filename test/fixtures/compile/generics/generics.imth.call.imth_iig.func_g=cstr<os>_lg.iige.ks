#![libstd(off)]

extern system class Array<T>

disclose Array<T> {
	splice(start: Number = 0, deleteCount: Number = 0, ...items: T): T[]
}

type Named = {
	name: String
}

func foobar<T is Named>(values: T[]) {
	values.splice(0, 4, values[0])
}
extern console

type Named = {
	name: String
}

func foobar<T is Named>(value: T) {
	echo(`\(value.name)`)
}

func quxbaz(value, log: Function) {
	log(value)
}

type Aged = Named & {
	age: Number
}

quxbaz({ name: 'Hello!', age: 0 }, foobar<Aged>^^(^))
quxbaz({ name: 'Hello!' }, console.log)
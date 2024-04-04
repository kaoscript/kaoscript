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

type Aged = {
	name: String
	age: Number
}

quxbaz<Aged>({ name: 'Hello!' }, foobar)
quxbaz({ name: 'Hello!' }, console.log)
func foobar<T>({ name: String }: T, value: T) {
	echo(`\(name)`)
	echo(`\(value.name)`)
}
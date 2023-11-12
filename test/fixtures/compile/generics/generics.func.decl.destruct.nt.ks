func foobar<T>({ name }: T, value: T) {
	echo(`\(name)`)
	echo(`\(value.name)`)
}
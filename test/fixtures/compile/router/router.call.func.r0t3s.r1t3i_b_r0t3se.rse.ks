func foobar(...{0,3}args: String): String {
	return '0'
}
func foobar(...{1,3}values: Number, flag: Boolean, ...{0,3}args: String): Number {
	return 1
}

func f(...args: String) => `\(foobar(...args))`
#![libstd(package="npm:@kaoscript/test-import/src/libstd.array.ks")]

func foobar(values: String[]) {
	if var value ?= values.pop() {
		print(`\(value)`)
	}
}
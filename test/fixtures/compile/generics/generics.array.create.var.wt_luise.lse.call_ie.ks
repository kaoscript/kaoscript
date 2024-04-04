#![libstd(package='npm:@kaoscript/runtime/src/libstd/atomic.ks')]

extern system class Array<T> {
	push(...elements: T): Number
}

func foobar(x: String, y: Number) {
	var result: Array<Number | String> = [x]

	echo(`\(result[0])`)

	result.push(y)

	echo(`\(result[0])`)
}
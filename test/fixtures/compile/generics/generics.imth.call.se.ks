class Foobar {
	foobar<T>(x: T): T {
		return x
	}
}

var value = Foobar.new()

echo(`\(value.foobar('hello'))`)
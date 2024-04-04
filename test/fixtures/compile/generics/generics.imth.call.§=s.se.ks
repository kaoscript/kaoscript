class Foobar {
	foobar<T is String>(x: T): T {
		return x
	}
}

var value = Foobar.new()

echo(`\(value.foobar('hello'))`)
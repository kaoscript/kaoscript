namespace T {
	export class FooX {
	}

	var fox = FooX.new()
}

var fox = T.FooX.new()

class FooY extends T.FooX {
}

var foy = FooY.new()
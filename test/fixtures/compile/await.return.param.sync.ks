func foo(x, y) async => x - y

func bar() async => qux(await foo(42, 24), await foo(4, 2))

func qux(x, y) => x * y
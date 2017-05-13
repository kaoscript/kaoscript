func foo(x, y) async => x - y

func bar() async => 3 * (await foo(42, 24))
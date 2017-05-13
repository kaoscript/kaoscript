func foo(x, y) async => x - y

func bar() async => (await foo(42, 24)) * 3
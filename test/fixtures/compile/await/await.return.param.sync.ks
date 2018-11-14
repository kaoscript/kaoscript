async func foo(x, y) => x - y

async func bar() => qux(await foo(42, 24), await foo(4, 2))

func qux(x, y) => x * y
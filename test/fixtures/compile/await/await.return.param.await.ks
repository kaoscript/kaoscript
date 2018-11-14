async func foo(x, y) => x - y

async func bar() => await foo(await foo(42, 24), await foo(4, 2))
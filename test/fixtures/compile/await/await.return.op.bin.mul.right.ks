async func foo(x, y) => x - y

async func bar() => 3 * (await foo(42, 24))
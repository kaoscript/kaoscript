async func foo(x, y) => x - y

async func bar() => (await foo(42, 24)) * 3
namespace T {
	export class FooX {
	}

	const fox = new FooX()
}

const fox = new T.FooX()

class FooY extends T.FooX {
}

const foy = new FooY()
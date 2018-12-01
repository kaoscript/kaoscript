extern sealed class Error

export class Foobar {
	foo() ~ Exception {
	}
}

export class Exception extends Error {
	static {
		throwFoobar(name) ~ Exception {
		}
	}
}
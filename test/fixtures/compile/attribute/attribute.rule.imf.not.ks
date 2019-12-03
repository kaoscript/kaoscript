#![rules(ignore-misfit)]

func foobar(x: String) {
}

foobar(42)

namespace Foobar {
	#![rules(dont-ignore-misfit)]

	foobar(42)
}
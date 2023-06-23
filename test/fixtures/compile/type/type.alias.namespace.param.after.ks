namespace Foobar {
	type Matcher = {
		match(name: String): Array
	}

	func quxbaz({ match }: Matcher) {
	}

	export Matcher
}

func quxbaz({ match }: Foobar.Matcher) {
}
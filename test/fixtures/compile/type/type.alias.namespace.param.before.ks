func quxbaz({ match }: Foobar.Matcher) {
}

namespace Foobar {
	type Matcher = {
		match(name: String): Array
	}

	func quxbaz({ match }: Matcher) {
	}

	export Matcher
}
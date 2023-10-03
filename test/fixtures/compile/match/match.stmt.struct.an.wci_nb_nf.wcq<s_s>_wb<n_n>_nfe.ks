struct Foobar {
	argument: String
	from: String
}

func foobar(value?) {
	match value {
		Number {
		}
		Foobar with var { argument, from } {
			echo(`\(from): \(argument)`)
		}
	}
}
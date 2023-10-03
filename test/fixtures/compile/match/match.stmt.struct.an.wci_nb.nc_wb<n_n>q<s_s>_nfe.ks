struct Foobar {
	argument: String
	from: String
}

func foobar(value?) {
	match value {
		Number {
		}
		with var { argument, from }: Foobar {
			echo(`\(from): \(argument)`)
		}
	}
}
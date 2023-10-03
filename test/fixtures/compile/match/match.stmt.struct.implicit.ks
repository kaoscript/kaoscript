struct Foobar {
	argument: String
	from: String
}

func foobar(value?) {
	match value {
		Number {
		}
		Foobar {
			echo(`\(.from): \(.argument)`)
		}
	}
}
struct Foobar {
	argument
	from
}

func foobar(value?) {
	match value {
		Number {
		}
		Foobar with { argument, from } {
		}
	}
}
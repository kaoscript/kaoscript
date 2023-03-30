struct Foobar {
	argument
	from
}

func foobar(value?) {
	match value {
		Number {
		}
		Array with [{ argument, from }: Foobar] {
		}
	}
}

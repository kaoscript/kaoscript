enum Kind {
	Foobar
}

type Foobar = {
	variant kind: Kind {
		Foobar {
			flag: Boolean
		}
	}
	name: String
}

func foobar(value: Foobar) {
	if value is .Foobar -> value.flag {
		echo(`\(value.name)`)
	}
}
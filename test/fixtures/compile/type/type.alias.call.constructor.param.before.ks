type Quxbaz = {
	name: String
}

func foobar() {
	return Corge.new()
}

type Foobar = {
	name: String
}

class Corge {
	private {
		@foobars: Foobar[]
		@quxbazs: Quxbaz[]
	}
	constructor(@foobars = [], @quxbazs = []) {
	}
}
class Foobar {
	debug(): Void {
	}
}

type Data = Foobar

impl Data {
	debug(): Void {
	}
}

func foobar(data: Data) {
	data.debug()
}
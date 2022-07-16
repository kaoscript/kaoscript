#![rules(ignore-misfit)]

abstract class Foobar {
	foobar() => ''
}

class Quxbaz {
}

struct Cursor {
	argument: Quxbaz | Foobar
}

func foobar(cursor: Cursor) => cursor.argument.foobar()
func foobar() {
	return null
}

var dyn x

while #[overwrite] var {x} ?= foobar() {
}


while {x} ?= foobar() {
}
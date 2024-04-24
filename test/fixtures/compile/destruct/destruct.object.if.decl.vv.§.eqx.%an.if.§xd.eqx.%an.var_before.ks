func foobar() {
	return null
}

var dyn x

if #[overwrite] var {x} ?= foobar() {
}

if {x} ?= foobar() {
}
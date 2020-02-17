impl Date {
	foobar(): Number => 0
}

class FDate extends Date {
	foobar(): Number => super.foobar()
}
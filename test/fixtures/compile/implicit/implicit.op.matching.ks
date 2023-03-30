bitmask Foobar {
	A
	B
	C
}

func foobar(kind: Foobar) {
	if kind ~~ .A {
	}
}
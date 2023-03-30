struct Foobar {
	x: Number
	y: Number
}

[new Foobar(0, 0)].map(({ x }, _, _) => x)
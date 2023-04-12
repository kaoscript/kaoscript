struct Foobar {
	x: Number
	y: Number
}

[Foobar.new(0, 0)].map(({ x }, _, _) => x)
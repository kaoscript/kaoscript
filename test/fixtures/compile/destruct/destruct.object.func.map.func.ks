struct Foobar {
	x: Number
	y: Number
}

func quxbaz({ x }, _, _) => x

[new Foobar(0, 0)].map(quxbaz)
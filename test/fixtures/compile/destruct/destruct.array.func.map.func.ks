tuple Foobar {
	x: Number
	y: Number
}

func quxbaz([ x ], _, _) => x

[Foobar.new(0, 0)].map(quxbaz)
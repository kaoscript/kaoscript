tuple Foobar {
	x: Number
	y: Number
}

[Foobar(0, 0)].map(([ x ], _, _) => x)
tuple Pair [ :String, :Number ]

tuple Triple extends Pair [ :Boolean ]

func print([x, y]: Pair) {
}

func foobar(t: Triple) {
	print(t)
}
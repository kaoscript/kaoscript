struct Foobar {
	a: Number?	= null
	b: Number?	= null
	c: Number?	= null
	d: Number?	= null
}

func foobar(values, test) {
	values.push(new Foobar(
		a: 1
		c: 3
		d: 4 if test()
	))
}
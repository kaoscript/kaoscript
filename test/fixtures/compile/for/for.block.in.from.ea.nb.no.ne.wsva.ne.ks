extern console

func foobar(heroes, inc) {
	for var hero, index in heroes step inc {
		console.log('The hero at index %d is %s', index, hero)
	}
}
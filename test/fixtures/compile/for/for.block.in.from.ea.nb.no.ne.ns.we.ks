extern console

func foobar(heroes) {
	for hero, index in heroes {
		console.log('The hero at index %d is %s', index, hero)
	}
	else {
		console.log('no heroes')
	}
}
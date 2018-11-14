extern console: {
	log(...args)
}

heroes = ['leto', 'duncan', 'goku']

for hero, index in heroes {
	console.log('The hero at index %d is %s', index, hero)
}
extern console: {
	log(...args)
}

var heroes = ['leto', 'duncan', 'goku']

for var hero, index in heroes when index % 2 == 0 {
	console.log('The hero at index %d is %s', index, hero)
}
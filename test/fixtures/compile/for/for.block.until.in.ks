extern console: {
	log(...args)
}

var heroes = ['leto', 'duncan', 'goku']

for var hero, index in heroes until index == 1 {
	console.log('The hero at index %d is %s', index, hero)
}
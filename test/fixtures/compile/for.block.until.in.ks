extern console: {
	log(...args)
}

heroes = ['leto', 'duncan', 'goku']

for hero, index in heroes until index = 1 {
	console.log('The hero at index %d is %s', index, hero)
}
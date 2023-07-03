extern console: {
	log(...args)
}

var heroes = ['leto', 'duncan', 'goku', 'batman', 'asterix', 'naruto', 'totoro']

for var hero, index in heroes from 5 to 2 step -3 {
	console.log('The hero at index %d is %s', index, hero)
}
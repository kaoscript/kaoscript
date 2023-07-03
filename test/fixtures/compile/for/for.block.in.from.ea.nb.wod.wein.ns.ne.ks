extern console: {
	log(...args)
}

var heroes = ['leto', 'duncan', 'goku', 'batman', 'asterix', 'naruto', 'totoro']

for var hero, index in heroes down to~ -2 {
	console.log('The hero at index %d is %s', index, hero)
}

// asterix, batman, goku, duncan, leto
extern console: {
	log(...args)
}

var heroes = ['leto', 'duncan', 'goku', 'batman', 'asterix', 'naruto', 'totoro']

for var hero, index in heroes to~ 2 {
	console.log('The hero at index %d is %s', index, hero)
}

// leto, duncan
extern console: {
	log(...args)
}

var heroes = ['leto', 'duncan', 'goku', 'batman', 'asterix', 'naruto', 'totoro']

for var hero, index in heroes from 2 to 5 step 2 {
	console.log('The hero at index %d is %s', index, hero)
}

// goku, asterix
extern console: {
	log(...args)
}

heroes = ['leto', 'duncan', 'goku', 'batman', 'asterix', 'naruto', 'totoro']

for hero, index in heroes desc from 2 to 5 by 2 {
	console.log('The hero at index %d is %s', index, hero)
}

// naruto, batman
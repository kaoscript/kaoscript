extern console: {
	log(...args)
}

heroes = ['leto', 'duncan', 'goku', 'batman', 'asterix', 'naruto', 'totoro']

for hero, index in heroes to~ -2 {
	console.log('The hero at index %d is %s', index, hero)
}

// leto, duncan, goku, batman, asterix
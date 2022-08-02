extern console: {
	log(...args)
}

var dyn hero = 'you'
var dyn index = 42

heroes = ['leto', 'duncan', 'goku']

for var hero, index in heroes {
	console.log('The hero at index %d is %s', index, hero)
}
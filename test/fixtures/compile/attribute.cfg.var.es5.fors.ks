#![cfg(format(variables='es5'))]

extern console: {
	log(...args)
}

for x from 0 til 10 {
	console.log(x)
}

for x in 0..10 {
	console.log(x)
}

heroes = ['leto', 'duncan', 'goku']

for hero, index in heroes {
	console.log('The hero at index %d is %s', index, hero)
}

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for key, value of likes {
	console.log(`\(key) likes \(value)`)
}
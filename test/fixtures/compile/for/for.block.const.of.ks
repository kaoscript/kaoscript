extern console: {
	log(...args)
}

var dyn key = 'you'
var dyn value = 42

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for var value, key of likes {
	console.log(`\(key) likes \(value)`)
}
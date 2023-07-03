extern console: {
	log(...args)
}

var likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for var value, key of likes when key.indexOf('a') != 0 {
	console.log(`\(key) likes \(value)`)
}
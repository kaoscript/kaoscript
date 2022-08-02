extern console: {
	log(...args)
}

var likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for value, key of likes {
	console.log(`\(key) likes \(value)`)
}
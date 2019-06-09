extern console: {
	log(...args)
}

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for value, key of likes when key.indexOf('a') != 0 {
	console.log(`\(key) likes \(value)`)
}
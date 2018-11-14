extern console: {
	log(...args)
}

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for key, value of likes when key.indexOf('a') != 0 {
	console.log(`\(key) likes \(value)`)
}
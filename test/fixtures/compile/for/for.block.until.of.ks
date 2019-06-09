extern console: {
	log(...args)
}

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for value, key of likes until value == 'chani' {
	console.log(`\(key) likes \(value)`)
}
extern console: {
	log(...args)
}

const likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for value, key of likes {
	console.log(`\(key) likes \(value)`)
}
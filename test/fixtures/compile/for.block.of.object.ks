extern console: {
	log(...args)
}

const likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for key, value of likes {
	console.log(`\(key) likes \(value)`)
}
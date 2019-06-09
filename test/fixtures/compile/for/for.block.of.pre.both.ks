extern console: {
	log(...args)
}

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

let key, value
for value, key of likes {
}

console.log(`\(key) likes \(value)`)
extern console: {
	log(...)
}

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

var dyn key, value
for value, key of likes {
}

console.log(`\(key) likes \(value)`)
extern console: {
	log(...args)
}

let key = 'you'
let value = 42

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for let key, value of likes {
	console.log(`\(key) likes \(value)`)
}
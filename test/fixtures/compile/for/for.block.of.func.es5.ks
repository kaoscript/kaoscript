#![target(ecma-v5)]

extern console: {
	log(...args)
}

func likes() => {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for key, value of likes() {
	console.log(`\(key) likes \(value)`)
}
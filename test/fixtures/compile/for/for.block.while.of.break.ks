extern console

var likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for var value, key of likes while value.length <= 5 {
	console.log(`\(key) likes \(value)`)
}
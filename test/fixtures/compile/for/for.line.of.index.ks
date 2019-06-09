extern console: {
	log(...args)
}

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

console.log('%s likes %s', key, value) for value, key of likes
func update(address) {
	address?
		..setStreet('Elm', '13a')
		..city = 'Carthage'
		..state = 'Eurasia'
		..zip(66666, extended: 6666)
}
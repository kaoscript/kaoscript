extern console: {
	log(...args)
}

class Matcher {
	private {
		_likes = {
			leto: 'spice'
			paul: 'chani'
			duncan: 'murbella'
		}
	}
	print() {
		for var value, key of @likes {
			console.log(`\(key) likes \(value)`)
		}
	}
}
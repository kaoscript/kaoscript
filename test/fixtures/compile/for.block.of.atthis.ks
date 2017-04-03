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
		for key, value of @likes {
			console.log(`\(key) likes \(value)`)
		}
	}
}
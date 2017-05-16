extern foo

class ClassA {
	constructor() {
		try {
			foo()
		}
		catch error {
			throw error
		}
	}
}
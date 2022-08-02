class Master {
	name() => 'Master'
}

class Subby extends Master {
	constructor() {
		super()

		var name = super.name()
	}
	name() => 'Subby'
}
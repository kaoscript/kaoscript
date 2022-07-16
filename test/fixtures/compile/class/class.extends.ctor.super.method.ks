class Master {
	name() => 'Master'
}

class Subby extends Master {
	constructor() {
		super()

		const name = super.name()
	}
	name() => 'Subby'
}
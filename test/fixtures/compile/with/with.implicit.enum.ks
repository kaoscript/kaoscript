bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(person) {
	with person {
		quxbaz(.CanFly, .firstname)
	}
}

func quxbaz(animal: AnimalFlags, name) {
}
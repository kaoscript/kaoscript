bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(mut animal: AnimalFlags?) {
	if !?animal {
		animal = .None
	}

	quxbaz(animal)
}

func quxbaz(animal: AnimalFlags) {
}
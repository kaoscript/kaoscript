bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(mut animal: AnimalFlags?) {
	animal ??= .None

	quxbaz(animal)
}

func quxbaz(animal: AnimalFlags) {
}
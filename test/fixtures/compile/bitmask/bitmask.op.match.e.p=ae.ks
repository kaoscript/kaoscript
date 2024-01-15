bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(animal: AnimalFlags, requirements) {
	if animal ~~ requirements {
	}
}
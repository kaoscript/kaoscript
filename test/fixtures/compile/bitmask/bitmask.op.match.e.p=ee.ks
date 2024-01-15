bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(animal: AnimalFlags, requirement: AnimalFlags) {
	if animal ~~ requirement {
	}
}
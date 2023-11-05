bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered

	Predator = CanFly + HasClaws
	FlyingPredator = Predator
}

func foobar(animal: AnimalFlags) {
	if animal ~~ .Predator {
	}
}
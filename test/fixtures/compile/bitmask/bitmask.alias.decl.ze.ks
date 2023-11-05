bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered

	Predator = CanFly + HasClaws
	FlyingPredator = Predator
}
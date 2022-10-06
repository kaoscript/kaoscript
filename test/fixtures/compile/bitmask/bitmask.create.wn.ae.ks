bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered

	EndangeredFlyingClawedFishEating = HasClaws + CanFly + EatsFish + Endangered
	Predator = CanFly + HasClaws
}

func flags(value): AnimalFlags? {
	return AnimalFlags(value)
}
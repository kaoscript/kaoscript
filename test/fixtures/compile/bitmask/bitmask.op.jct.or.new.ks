bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered

	EndangeredFlyingClawedFishEating = HasClaws || CanFly || EatsFish || Endangered
	Predator = CanFly || HasClaws
}
bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func isEndangered(animal: AnimalFlags?): Boolean {
	return animal ~~ AnimalFlags.Endangered
}
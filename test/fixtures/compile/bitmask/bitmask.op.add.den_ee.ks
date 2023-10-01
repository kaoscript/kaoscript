bitmask AnimalFlags {
	None**
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func setEndangered(animal: AnimalFlags?): AnimalFlags {
	return **animal + AnimalFlags.Endangered
}
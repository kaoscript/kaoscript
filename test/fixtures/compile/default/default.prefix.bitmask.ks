bitmask AnimalFlags {
	None**
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(animal: AnimalFlags?): AnimalFlags {
	return **animal + .Endangered
}
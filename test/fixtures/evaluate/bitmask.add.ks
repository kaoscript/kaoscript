require expect: func

bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func setEndangered(animal: AnimalFlags = .None): AnimalFlags {
	return animal + AnimalFlags.Endangered
}

expect(setEndangered(null)).to.eql(AnimalFlags.Endangered)
expect(setEndangered(.CanFly)).to.eql(AnimalFlags.CanFly + AnimalFlags.Endangered)
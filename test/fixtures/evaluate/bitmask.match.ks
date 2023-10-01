require expect: func

bitmask AnimalFlags {
	None**
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func isEndangered(animal: AnimalFlags?): Boolean {
	return **animal ~~ .Endangered
}

expect(isEndangered(null)).to.equal(false)
expect(isEndangered(.CanFly)).to.equal(false)
expect(isEndangered(.Endangered)).to.equal(true)
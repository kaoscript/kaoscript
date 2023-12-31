require expect: func

bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered

	EndangeredFlyingClawedFishEating = HasClaws + CanFly + EatsFish + Endangered
	Predator = CanFly + HasClaws
}

type Animal = {
	name: String
    features: AnimalFlags
}

func restore(mut animal) {
	animal = animal:>(Animal)
}

var mut data = {
	name: 'eagle'
	features: 3
}

expect(data.features).to.equal(3)
expect(data.features).to.not.equal(AnimalFlags.Predator)

restore(data)

expect(data.features).to.not.equal(3)
expect(data.features).to.equal(AnimalFlags.Predator)
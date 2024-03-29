extern console

bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered

	EndangeredFlyingClawedFishEating = HasClaws + CanFly + EatsFish + Endangered
	Predator = CanFly + HasClaws
}

func printAnimalAbilities(animal) {
	var animalFlags: Number = animal.flags.value

	if (animalFlags +& AnimalFlags.HasClaws.value) != 0 {
		console.log('animal has claws')
	}

	if (animalFlags +& AnimalFlags.CanFly.value) != 0 {
		console.log('animal can fly')
	}

	if animalFlags == AnimalFlags.None.value {
		console.log('nothing')
	}
}

var dyn animal = {
	flags: AnimalFlags.None
}

printAnimalAbilities(animal)
// -> nothing

animal.flags += AnimalFlags.HasClaws
printAnimalAbilities(animal)
// -> animal has claws

animal.flags -= AnimalFlags.HasClaws
printAnimalAbilities(animal)
// -> nothing

animal.flags += AnimalFlags.HasClaws + AnimalFlags.CanFly
printAnimalAbilities(animal)
// -> animal has claws, animal can fly

export AnimalFlags, printAnimalAbilities
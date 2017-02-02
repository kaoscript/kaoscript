extern console

#[flags]
enum AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
	
	EndangeredFlyingClawedFishEating = HasClaws | CanFly | EatsFish | Endangered
}

func printAnimalAbilities(animal) {
	let animalFlags = animal.flags
	
	if animalFlags & AnimalFlags::HasClaws {
		console.log('animal has claws')
	}
	
	if animalFlags & AnimalFlags::CanFly {
		console.log('animal can fly')
	}
	
	if animalFlags == AnimalFlags::None {
		console.log('nothing')
	}
}

let animal = {
	flags: AnimalFlags::None
}

printAnimalAbilities(animal)
// -> nothing

animal.flags |= AnimalFlags::HasClaws
printAnimalAbilities(animal)
// -> animal has claws

animal.flags &= ~AnimalFlags::HasClaws
printAnimalAbilities(animal)
// -> nothing

animal.flags |= AnimalFlags::HasClaws | AnimalFlags::CanFly
printAnimalAbilities(animal)
// -> animal has claws, animal can fly
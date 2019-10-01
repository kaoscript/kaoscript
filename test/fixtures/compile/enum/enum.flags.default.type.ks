extern console

#[flags]
enum AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered

	EndangeredFlyingClawedFishEating = HasClaws | CanFly | EatsFish | Endangered
	Predator = CanFly | HasClaws
}

func foobar(x: Number) {
}

foobar(AnimalFlags::Predator)

func printAnimalAbilities(abilities: AnimalFlags) {
	if abilities & AnimalFlags::HasClaws != 0 {
		console.log('animal has claws')
	}

	if abilities & AnimalFlags::CanFly != 0 {
		console.log('animal can fly')
	}

	if abilities == AnimalFlags::None {
		console.log('nothing')
	}
}

let abilities := AnimalFlags::None

printAnimalAbilities(abilities)

abilities |= AnimalFlags::HasClaws

printAnimalAbilities(abilities)

abilities &= ~AnimalFlags::HasClaws
printAnimalAbilities(abilities)

abilities |= AnimalFlags::HasClaws | AnimalFlags::CanFly
printAnimalAbilities(abilities)

printAnimalAbilities(AnimalFlags::HasClaws | AnimalFlags::CanFly)

printAnimalAbilities(AnimalFlags::HasClaws | AnimalFlags::CanFly | AnimalFlags::Endangered)

func quxbaz(x) {
	let abex
	if x {
		abex = AnimalFlags::HasClaws | AnimalFlags::CanFly | AnimalFlags::Endangered
	}
	else {
		abex = AnimalFlags::HasClaws | AnimalFlags::CanFly
	}

	let abey: AnimalFlags
	if x {
		abey = AnimalFlags::HasClaws | AnimalFlags::CanFly | AnimalFlags::Endangered
	}
	else {
		abey = AnimalFlags::HasClaws | AnimalFlags::CanFly
	}

	let abez: Number
	if x {
		abez = AnimalFlags::HasClaws | AnimalFlags::CanFly | AnimalFlags::Endangered
	}
	else {
		abez = AnimalFlags::HasClaws | AnimalFlags::CanFly
	}
}
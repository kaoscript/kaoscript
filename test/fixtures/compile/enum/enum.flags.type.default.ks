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
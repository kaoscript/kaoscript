extern console

bitmask AnimalFlags<u128> {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered

	EndangeredFlyingClawedFishEating = HasClaws + CanFly + EatsFish + Endangered
	Predator = CanFly + HasClaws
}

func foobar(x: Number) {
}

foobar(AnimalFlags::Predator)

func printAnimalAbilities(abilities: AnimalFlags) {
	if abilities ~~ AnimalFlags::HasClaws {
		console.log('animal has claws')
	}

	if abilities ~~ AnimalFlags::CanFly {
		console.log('animal can fly')
	}

	if abilities == AnimalFlags::None {
		console.log('nothing')
	}
}

var mut abilities = AnimalFlags::None

printAnimalAbilities(abilities)

abilities += AnimalFlags::HasClaws

printAnimalAbilities(abilities)

abilities -= AnimalFlags::HasClaws
printAnimalAbilities(abilities)

abilities += AnimalFlags::HasClaws + AnimalFlags::CanFly
printAnimalAbilities(abilities)

abilities += AnimalFlags::HasClaws + AnimalFlags::CanFly + AnimalFlags::Endangered
printAnimalAbilities(abilities)

abilities -= AnimalFlags::HasClaws - AnimalFlags::CanFly
printAnimalAbilities(abilities)

abilities -= AnimalFlags::HasClaws - AnimalFlags::CanFly - AnimalFlags::Endangered
printAnimalAbilities(abilities)

printAnimalAbilities(AnimalFlags::HasClaws + AnimalFlags::CanFly)

printAnimalAbilities(AnimalFlags::HasClaws + AnimalFlags::CanFly + AnimalFlags::Endangered)

printAnimalAbilities(AnimalFlags::EndangeredFlyingClawedFishEating - AnimalFlags::HasClaws)

printAnimalAbilities(AnimalFlags::EndangeredFlyingClawedFishEating - AnimalFlags::HasClaws - AnimalFlags::CanFly)

func quxbaz(x) {
	var late abex
	if x {
		abex = AnimalFlags::HasClaws + AnimalFlags::CanFly + AnimalFlags::Endangered
	}
	else {
		abex = AnimalFlags::HasClaws + AnimalFlags::CanFly
	}

	var late abey: AnimalFlags
	if x {
		abey = AnimalFlags::HasClaws + AnimalFlags::CanFly + AnimalFlags::Endangered
	}
	else {
		abey = AnimalFlags::HasClaws + AnimalFlags::CanFly
	}

	var late abez: Number
	if x {
		abez = AnimalFlags::HasClaws + AnimalFlags::CanFly + AnimalFlags::Endangered
	}
	else {
		abez = AnimalFlags::HasClaws + AnimalFlags::CanFly
	}
}

var abyx = AnimalFlags::HasClaws + AnimalFlags::CanFly
var abyy = AnimalFlags::HasClaws + AnimalFlags::CanFly + AnimalFlags::Endangered
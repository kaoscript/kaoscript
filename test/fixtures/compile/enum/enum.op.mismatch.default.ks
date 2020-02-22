#[flags]
enum AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered

	EndangeredFlyingClawedFishEating = HasClaws + CanFly + EatsFish + Endangered
	Predator = CanFly + HasClaws
}

func foobar(abilities: AnimalFlags) {
	if abilities ~~ AnimalFlags::CanFly {

	}

	if abilities !~ AnimalFlags::CanFly {

	}
}
flagged enum AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(abilities: AnimalFlags) {
	if abilities ~~ AnimalFlags::CanFly {

	}

	if abilities !~ AnimalFlags::CanFly {

	}
}
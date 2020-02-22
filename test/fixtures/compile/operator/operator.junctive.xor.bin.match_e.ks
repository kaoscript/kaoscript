#[flags]
enum AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(abilities: AnimalFlags) {
	if abilities ~~ AnimalFlags::CanFly ^ AnimalFlags::EatsFish {
	}
}
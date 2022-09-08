bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func abilities(): AnimalFlags => AnimalFlags::None

if abilities() ~~ AnimalFlags::CanFly | AnimalFlags::EatsFish {
}
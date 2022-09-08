bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(mut animal: AnimalFlags) {
	animal = animal - AnimalFlags::CanFly + AnimalFlags::HasClaws
}
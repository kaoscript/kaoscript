flagged enum AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(mut animal: AnimalFlags) {
	animal = animal + AnimalFlags::HasClaws - AnimalFlags::CanFly
}
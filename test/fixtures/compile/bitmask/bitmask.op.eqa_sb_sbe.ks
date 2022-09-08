bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(mut animal: AnimalFlags) {
	animal += AnimalFlags::HasClaws - AnimalFlags::CanFly - AnimalFlags::Endangered
}
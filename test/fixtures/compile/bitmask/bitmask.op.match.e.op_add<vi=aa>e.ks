bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(animal: AnimalFlags) {
	if animal ~~ .HasClaws + .CanFly {
	}
}
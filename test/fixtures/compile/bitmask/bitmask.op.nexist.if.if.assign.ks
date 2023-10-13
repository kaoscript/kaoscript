bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(mut flags: AnimalFlags?, test) {
	if !?flags {
		if test() {
			flags = AnimalFlags.HasClaws + AnimalFlags.CanFly
		}
		else {
			flags = AnimalFlags.CanFly
		}
	}

	quxbaz(flags)
}

func quxbaz(flags: AnimalFlags) {
}
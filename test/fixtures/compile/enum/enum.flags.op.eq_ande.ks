flagged enum AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

var mut animal: AnimalFlags

animal = AnimalFlags::HasClaws && !AnimalFlags::CanFly
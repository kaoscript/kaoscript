bitmask AnimalFlags {
	None
	HasClaws
	CanFly
	EatsFish
	Endangered
}

func foobar(animal: AnimalFlags, req1, req2, req3) {
	if animal ~~ req1 + req2 + req3 {
	}
}
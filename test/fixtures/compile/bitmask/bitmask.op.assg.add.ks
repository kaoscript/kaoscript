bitmask State {
	Step0
	Step1
	Step2
	Step3
	Step4
}

func foobar(mut state: State) {
	state += .Step1
}
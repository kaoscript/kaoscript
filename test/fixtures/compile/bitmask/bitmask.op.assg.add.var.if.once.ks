bitmask State {
	Step0
	Step1
	Step2
	Step3
	Step4
}

func foobar(state: State): State {
	var mut result = State.Step0

	result += .Step1 if state ~~ .Step1

	return result
}
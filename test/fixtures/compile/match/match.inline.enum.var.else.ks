enum Accessibility {
	Internal = 1
	Private
	Protected
	Public
}

func isLessAccessibleThan(source: Accessibility, target: Accessibility): Boolean {
	var result = match source {
		.Protected	=> target == .Public
		.Private	=> target == .Protected | .Public
		.Internal	=> target == .Private | .Protected | .Public
		else		=> false
	}

	return result
}
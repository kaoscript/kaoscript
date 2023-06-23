enum Accessibility {
	Internal = 1
	Private
	Protected
	Public
}

func isLessAccessibleThan(source: Accessibility, target: Accessibility): Boolean {
	match source {
		.Protected {
			return target == .Public
		}
		.Private {
			return target == .Protected | .Public
		}
		.Internal {
			return target == .Private | .Protected | .Public
		}
	}

	return false
}
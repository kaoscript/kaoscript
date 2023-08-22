extern system class String

impl String {
	substringBefore(pattern: RegExp | String, position: Boolean, missingValue: String = ''): String {
		if position {
			return @substringBefore(pattern, -1, missingValue)
		}
		else {
			return @substringBefore(pattern, 0, missingValue)
		}
	}
	substringBefore(pattern: String, position: Number = 0, missingValue: String = ''): valueof this
	substringBefore(pattern: RegExp, position: Number = 0, missingValue: String = ''): valueof this
}
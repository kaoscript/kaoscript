
class Foobar {
	foobar(c: Boolean = true) {
		return 0
	}
	foobar(c: Number | String = 0, d: Number | String) {
		return 1
	}
	foobar(c: Number | String, d: Number | String, e: Dictionary | String, f: Boolean = true) {
		return 2
	}
}
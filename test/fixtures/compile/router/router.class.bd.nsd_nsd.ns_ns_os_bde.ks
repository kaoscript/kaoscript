
class Foobar {
	foobar(c: Boolean = true) {
		return 0
	}
	foobar(c: Number | String = 0, d: Number | String = 0) {
		return 1
	}
	foobar(c: Number | String, d: Number | String, e: Object | String, f: Boolean = true) {
		return 2
	}
}
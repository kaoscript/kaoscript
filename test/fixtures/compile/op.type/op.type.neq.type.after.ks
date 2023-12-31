func foobar(result: MayResult) {
	if result is not NoResult {
	}
}

struct Result {
	value?
}

struct NoResult {
	message: String?
}

type MayResult = Result | NoResult
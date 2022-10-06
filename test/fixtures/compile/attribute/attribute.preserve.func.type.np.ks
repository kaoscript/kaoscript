extern {
	func it(title: String, fn: (#[preserve] done: Function): Void)
}

func test(done) {
	done()
}

it('print', test)
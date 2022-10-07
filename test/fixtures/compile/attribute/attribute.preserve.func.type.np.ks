extern {
	func it(title: String, fn: (#[retain] done: Function): Void)
}

func test(done) {
	done()
}

it('print', test)
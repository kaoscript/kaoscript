extern {
	func it(title: String, fn: (#[preserve] done: Function): Void)
}

func test(#[preserve] done) {
	done()
}

it('print', test)
extern {
	func it(title: String, fn: (#[retain] done: Function): Void)
}

func test(#[retain] done) {
	done()
}

it('print', test)
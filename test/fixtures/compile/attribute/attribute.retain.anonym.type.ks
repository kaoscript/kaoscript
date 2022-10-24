extern {
	func it(title: String, fn: (#[retain] done: Function): Void)
}

it('print', func(done) {
	done()
})
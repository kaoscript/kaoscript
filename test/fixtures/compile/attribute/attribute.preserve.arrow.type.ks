extern {
	func it(title: String, fn: (#[preserve] done: Function): Void)
}

it('print', (done) => {
	done()
})
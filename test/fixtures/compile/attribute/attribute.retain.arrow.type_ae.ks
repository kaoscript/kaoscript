extern {
	func it(title: String, fn: (#[retain] done): Void)
}

it('print', (done) => {
	done()
})
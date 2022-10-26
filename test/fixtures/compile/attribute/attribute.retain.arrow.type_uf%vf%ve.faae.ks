extern {
	func it(title: String, fn: (#[retain] done: Function): Void || (): Void)
}

it('print', (done, x) => {
	done()
})
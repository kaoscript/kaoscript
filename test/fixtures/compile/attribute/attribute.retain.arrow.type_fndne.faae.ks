extern {
	func it(title: String, fn: (#[retain] done: Function? = null): Void)
}

it('print', (done, x) => {
	done()
})
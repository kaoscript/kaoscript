extern {
	func it(title: String, fn: (#[retain] done: Function) | ())
}

it('print', (done, x) => {
})
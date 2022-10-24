extern {
	func it(...)
}

it('print', (#[retain] done) => {
	done()
})
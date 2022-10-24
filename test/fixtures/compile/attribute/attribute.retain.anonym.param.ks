extern {
	func it(...)
}

it('print', func(#[retain] done) {
	done()
})
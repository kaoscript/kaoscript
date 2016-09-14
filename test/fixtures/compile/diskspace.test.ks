#![bin]

extern {
	describe:	func
	it:			func
	console
}

import {
	expect 		from chai
	*			from ./polyfill.ks
	*			from ./diskspace.module.ks
}

describe('diskspace', func() {
	it('print', func(done) { // {{{
		let d = await disks()
		
		expect(d).to.have.length.above(0)
		
		done()
	}) // }}}
})
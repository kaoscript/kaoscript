#![bin]

extern {
	describe:	func
	it:			func
	console
}

import {
	expect 		from chai
	*			from ./diskspace.module.ks
}

describe('diskspace', func() {
	it('print', func(done) { // {{{
		let d = await disks()
		
		expect(d).to.have.length.above(0)
		
		console.log(d)
		
		done()
	}) // }}}
})
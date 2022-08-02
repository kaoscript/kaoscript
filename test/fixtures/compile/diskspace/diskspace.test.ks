#![bin]

extern {
	describe:	func
	it:			func
	console
}

import {
	'chai' for expect
	'./diskspace.module.ks'
}

describe('diskspace', func() {
	it('print', func(done) { // {{{
		var dyn d = await disks()
		
		expect(d).to.have.length.above(0)
		
		console.log(d)
		
		done()
	}) // }}}
})
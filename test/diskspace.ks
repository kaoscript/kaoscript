#![bin]

extern {
	describe:	func
	it:			func
	console
}

import {
	expect 		from chai
	*			from ./fixtures/compile/diskspace.module.ks
}

describe('diskspace', func() {
	it('print', func(done) { // {{{
		let d = await disks()
		
		console.log(d)
		
		done()
	}) // }}}
})
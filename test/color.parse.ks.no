#![bin]

extern {
	describe:	func
	it:			func
}

import {
	expect 		from chai
	*			from ./fixtures/compile/color.ks
}

describe('color.parse', func() {
	describe('hex', func() {
		it('#ddd', func() { // {{{
			let c = new Color('#ddd')
			
			expect(c.red()).equal(221)
			expect(c.green()).equal(221)
			expect(c.blue()).equal(221)
			expect(c.alpha()).equal(1)
		}) // }}}
		
		it('#808080', func() { // {{{
			let c = new Color('#808080')
			
			expect(c.red()).equal(128)
			expect(c.green()).equal(128)
			expect(c.blue()).equal(128)
			expect(c.alpha()).equal(1)
		}) // }}}
		
		it('#ddda', func() { // {{{
			let c = new Color('#ddda')
			
			expect(c.red()).equal(221)
			expect(c.green()).equal(221)
			expect(c.blue()).equal(221)
			expect(c.alpha()).equal(0.667)
		}) // }}}
		
		it('#808080A0', func() { // {{{
			let c = new Color('#808080A0')
			
			expect(c.red()).equal(128)
			expect(c.green()).equal(128)
			expect(c.blue()).equal(128)
			expect(c.alpha()).equal(0.627)
		}) // }}}
	})
	
	describe('rgb', func() {
		it('rgb(128, 128, 128)', func() { // {{{
			let c = new Color('rgb(128, 128, 128)')
			
			expect(c.red()).equal(128)
			expect(c.green()).equal(128)
			expect(c.blue()).equal(128)
			expect(c.alpha()).equal(1)
		}) // }}}
		
		it('rgb(50%, 50%, 50%)', func() { // {{{
			let c = new Color('rgb(50%, 50%, 50%)')
			
			expect(c.red()).equal(127)
			expect(c.green()).equal(127)
			expect(c.blue()).equal(127)
			expect(c.alpha()).equal(1)
		}) // }}}
		
		it('rgba(128, 128, 128, 0.7)', func() { // {{{
			let c = new Color('rgba(128, 128, 128, 0.7)')
			
			expect(c.red()).equal(128)
			expect(c.green()).equal(128)
			expect(c.blue()).equal(128)
			expect(c.alpha()).equal(0.7)
		}) // }}}
		
		it('rgba(50%, 50%, 50%, 70%)', func() { // {{{
			let c = new Color('rgba(50%, 50%, 50%, 70%)')
			
			expect(c.red()).equal(127)
			expect(c.green()).equal(127)
			expect(c.blue()).equal(127)
			expect(c.alpha()).equal(0.7)
		}) // }}}
		
		it('rgba(#808080, 0.7)', func() { // {{{
			let c = new Color('rgba(#808080, 0.7)')
			
			expect(c.red()).equal(128)
			expect(c.green()).equal(128)
			expect(c.blue()).equal(128)
			expect(c.alpha()).equal(0.7)
		}) // }}}
		
		it('rgba(#808080, 70%)', func() { // {{{
			let c = new Color('rgba(#808080, 70%)')
			
			expect(c.red()).equal(128)
			expect(c.green()).equal(128)
			expect(c.blue()).equal(128)
			expect(c.alpha()).equal(0.7)
		}) // }}}
		
		it('rgba(#ddd, 0.7)', func() { // {{{
			let c = new Color('rgba(#ddd, 0.7)')
			
			expect(c.red()).equal(221)
			expect(c.green()).equal(221)
			expect(c.blue()).equal(221)
			expect(c.alpha()).equal(0.7)
		}) // }}}
		
		it('rgba(#ddd, 70%)', func() { // {{{
			let c = new Color('rgba(#ddd, 70%)')
			
			expect(c.red()).equal(221)
			expect(c.green()).equal(221)
			expect(c.blue()).equal(221)
			expect(c.alpha()).equal(0.7)
		}) // }}}
	})
	
	describe('gray', func() {
		it('gray(128)', func() { // {{{
			let c = new Color('gray(128)')
			
			expect(c.red()).equal(128)
			expect(c.green()).equal(128)
			expect(c.blue()).equal(128)
			expect(c.alpha()).equal(1)
		}) // }}}
		
		it('gray(50%)', func() { // {{{
			let c = new Color('gray(50%)')
			
			expect(c.red()).equal(127)
			expect(c.green()).equal(127)
			expect(c.blue()).equal(127)
			expect(c.alpha()).equal(1)
		}) // }}}
		
		it('gray(128, 0.7)', func() { // {{{
			let c = new Color('gray(128, 0.7)')
			
			expect(c.red()).equal(128)
			expect(c.green()).equal(128)
			expect(c.blue()).equal(128)
			expect(c.alpha()).equal(0.7)
		}) // }}}
		
		it('gray(50%, 70%)', func() { // {{{
			let c = new Color('gray(50%, 70%)')
			
			expect(c.red()).equal(127)
			expect(c.green()).equal(127)
			expect(c.blue()).equal(127)
			expect(c.alpha()).equal(0.7)
		}) // }}}
	})
})
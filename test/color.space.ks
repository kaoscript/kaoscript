#![bin]

extern {
	describe:	func
	it:			func
}

import {
	expect 		from chai
	*			from @kaoscript/runtime
	*			from ./fixtures/compile/color.ks
}

describe('color.space', func() {
	describe('space', func() {
		it('get', func() { // {{{
			let c = new Color('#ff0')
			
			expect(c.space()).to.equal('srgb')
		}) // }}}
		
		it('set :rgb', func() { // {{{
			let c = new Color('#ff0')
			
			expect(c.space()).to.equal('srgb')
			
			c.space('rgb')
			
			expect(c.space()).to.equal('srgb')
		}) // }}}
		
		it('set :green', func() { // {{{
			let c = new Color('#ff0')
			
			expect(c.space()).to.equal('srgb')
			
			c.space('green')
			
			expect(c.space()).to.equal('srgb')
		}) // }}}
		
		it('set :hsb', func() { // {{{
			let c = new Color('#ff0')
			
			expect(c.space()).to.equal('srgb')
			
			let error
			try {
				c.space('hsb')
			}
			catch(e) {
				error = e
			}
			
			expect(error).to.exist
			expect(error.message).to.equal('It can\'t convert a color from \'srgb\' to \'hsb\' spaces.')
		}) // }}}
		
		it('like :rgb', func() { // {{{
			let c = new Color('#ff0')
			
			expect(c.space()).to.equal('srgb')
			
			expect(c.like('rgb').space()).to.equal('srgb')
			
			expect(c.space()).to.equal('srgb')
		}) // }}}
	})
	
	describe('rvb', func() {
		it('register', func() { // {{{
			Color.registerSpace({
				name: 'rvb',
				converters: {
					from: {
						srgb: func(red, green, blue, that) { // {{{
							that._rouge = red
							that._vert = green
							that._blue = blue
						} // }}}
					},
					to: {
						srgb: func(rouge, vert, blue, that) { // {{{
							that._red = rouge
							that._green = vert
							that._blue = blue
						} // }}}
					}
				},
				components: {
					rouge: {
						max: 255
					},
					vert: {
						max: 255
					},
					blue: {
						max: 255
					}
				}
			})
			
			let c = new Color('#ff0')
			
			expect(c.space()).to.equal('srgb')
			
			c.space('rvb')
			
			expect(c.space()).to.equal('rvb')
			
			expect(c.rouge()).to.equal(255)
			expect(c.vert()).to.equal(255)
			expect(c.blue()).to.equal(0)
		}) // }}}
		
		it('set :rouge', func() { // {{{
			let c = new Color('#ff0')
			
			expect(c.space()).to.equal('srgb')
			
			c.space('rouge')
			
			expect(c.space()).to.equal('rvb')
		}) // }}}
		
		it('like :rvb', func() { // {{{
			let c = new Color('#ff0')
			
			expect(c.space()).to.equal('srgb')
			
			expect(c.like('rvb')).to.eql({
				_alpha: 0,
				_blue: 0,
				_rouge: 255,
				_space: 'rvb',
				_vert: 255
			})
			
			expect(c.space()).to.equal('srgb')
		}) // }}}
	})
	
	describe('cmy', func() {
		it('register', func() { // {{{
			Color.registerSpace({
				name: 'cmy',
				converters: {
					from: {
						srgb: func(red, green, blue, that) { // {{{
							that._cyan = blue
							that._magenta = red
							that._yellow = green
						} // }}}
					},
					to: {
						srgb: func(cyan, magenta, yellow, that) { // {{{
							that._red = magenta
							that._green = yellow
							that._blue = cyan
						} // }}}
					}
				},
				components: {
					magenta: {
						max: 255
					},
					green: {
						max: 255
					},
					yellow: {
						max: 255
					}
				}
			})
		}) // }}}
		
		it('set :blue', func() { // {{{
			let c = new Color('#ff0')
			
			expect(c.space()).to.equal('srgb')
			
			c.space('cmy')
			
			expect(c.space()).to.equal('cmy')
			
			let error
			try {
				c.space('blue')
			}
			catch(e) {
				error = e
			}
			
			expect(error).to.exist
			expect(error.message).to.equal('The component \'blue\' has a conflict between the spaces \'srgb\', \'rvb\'')
		}) // }}}
	})
})
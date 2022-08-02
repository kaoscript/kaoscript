#![bin]

extern {
	describe:	func
	it:			func
}

import {
	'chai' for expect
	'./fixtures/compile/color.ks'
}

Color.registerSpace!({ // {{{ rvb
	name: 'rvb',
	converters: {
		from: {
			srgb(red, green, blue, that) { // {{{
				that._rouge = red
				that._vert = green
				that._blue = blue
			} // }}}
		},
		to: {
			srgb(rouge, vert, blue, that) { // {{{
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
}) // }}}

Color.registerSpace!({ // {{{ cmy
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
}) // }}}

describe('color.space', func() {
	describe('space', func() {
		it('get', func() { // {{{
			var c = new Color('#ff0')

			expect(c.space()).to.equal(Space::SRGB)
		}) // }}}

		it('set :rgb', func() { // {{{
			var c = new Color('#ff0')

			expect(c.space()).to.equal(Space::SRGB)

			c.space('rgb')

			expect(c.space()).to.equal(Space::SRGB)
		}) // }}}

		it('set :green', func() { // {{{
			var c = new Color('#ff0')

			expect(c.space()).to.equal(Space::SRGB)

			c.space('green')

			expect(c.space()).to.equal(Space::SRGB)
		}) // }}}

		it('set :hsb', func() { // {{{
			var c = new Color('#ff0')

			expect(c.space()).to.equal(Space::SRGB)

			var dyn error
			try {
				c.space('hsb')
			}
			catch e {
				error = e
			}

			expect(error).to.exist
			expect(error?.message).to.equal('It can\'t convert a color from \'srgb\' to \'hsb\' spaces.')
		}) // }}}

		it('like :rgb', func() { // {{{
			var c = new Color('#ff0')

			expect(c.space()).to.equal(Space::SRGB)

			expect(c.like('rgb').space()).to.equal(Space::SRGB)

			expect(c.space()).to.equal(Space::SRGB)
		}) // }}}
	})

	describe('rvb', func() {
		it('set :rvb', func() { // {{{
			var c = new Color('#ff0')

			expect(c.space()).to.equal(Space::SRGB)

			c.space('rvb')

			expect(c.space()).to.equal(Space::RVB)

			expect(c.rouge()).to.equal(255)
			expect(c.vert()).to.equal(255)
			expect(c.blue()).to.equal(0)
		}) // }}}

		it('set :rouge', func() { // {{{
			var c = new Color('#ff0')

			expect(c.space()).to.equal(Space::SRGB)

			c.space('rouge')

			expect(c.space()).to.equal(Space::RVB)
		}) // }}}

		it('like :rvb', func() { // {{{
			var c = new Color('#ff0')

			expect(c.space()).to.equal(Space::SRGB)

			expect(c.like('rvb')).to.eql({
				_alpha: 0,
				_blue: 0,
				_rouge: 255,
				_space: Space::RVB,
				_vert: 255
			})

			expect(c.space()).to.equal(Space::SRGB)
		}) // }}}
	})

	describe('cmy', func() {
		it('set :blue', func() { // {{{
			var c = new Color('#ff0')

			expect(c.space()).to.equal(Space::SRGB)

			c.space('cmy')

			expect(c.space()).to.equal(Space::CMY)

			var dyn error
			try {
				c.space('blue')
			}
			catch e {
				error = e
			}

			expect(error).to.exist
			expect(error?.message).to.equal('The component \'blue\' has a conflict between the spaces \'srgb\', \'rvb\'')
		}) // }}}
	})
})

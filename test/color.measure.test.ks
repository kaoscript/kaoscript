#![bin]

extern {
	describe:	func
	it:			func
}

import {
	'chai' for expect
	'./fixtures/compile/color.ks'
}

describe('color.measure', func() {
	it('contrast(#abc, #963)', func() { # {{{
		var c = new Color('#abc').contrast(Color.from('#963')!!)

		expect(c.ratio).to.equal(2.48)
		expect(c.error).to.equal(0)
	}) # }}}

	it('contrast(#abc, rgba(153, 102, 51, 0.5))', func() { # {{{
		var c = new Color('#abc').contrast(Color.from('rgba(153, 102, 51, 0.5)')!!)

		expect(c.ratio).to.equal(1.55)
		expect(c.error).to.equal(0)
	}) # }}}

	it('contrast(rgba(72, 23, 159, 0.9), rgba(153, 102, 51, 0.5))', func() { # {{{
		var c = new Color('rgba(72, 23, 159, 0.9)').contrast(Color.from('rgba(153, 102, 51, 0.5)')!!)

		expect(c.ratio).to.equal(1.41)
		expect(c.error).to.equal(0.07)
	}) # }}}

	it('distance', func() { # {{{
		var d = new Color('#abc').distance(Color.from('#963')!!)

		expect(d).to.equal(276.739950133695)
	}) # }}}

	it('isBlack(black)', func() { # {{{
		var c = new Color('black')

		expect(c.isBlack()).to.equal(true)
	}) # }}}

	it('isBlack(white)', func() { # {{{
		var c = new Color('white')

		expect(c.isBlack()).to.equal(false)
	}) # }}}

	it('isWhite(black)', func() { # {{{
		var c = new Color('black')

		expect(c.isWhite()).to.equal(false)
	}) # }}}

	it('isWhite(white)', func() { # {{{
		var c = new Color('white')

		expect(c.isWhite()).to.equal(true)
	}) # }}}

	it('isTransparent(#ff0)', func() { # {{{
		var c = new Color('#ff0')

		expect(c.isTransparent()).to.equal(false)
	}) # }}}

	it('isTransparent(#0000)', func() { # {{{
		var c = new Color('#0000')

		expect(c.isTransparent()).to.equal(true)
	}) # }}}

	it('isTransparent(transparent)', func() { # {{{
		var c = new Color('transparent')

		expect(c.isTransparent()).to.equal(true)
	}) # }}}

	it('luminance(#abc)', func() { # {{{
		var l = new Color('#abc').luminance()

		expect(l).to.equal(0.4844632879252147)
	}) # }}}

	it('luminance(#111)', func() { # {{{
		var l = new Color('#090909').luminance()

		expect(l).to.equal(0.0027317428519395373)
	}) # }}}

	it('luminance(#eee)', func() { # {{{
		var l = new Color('#eee').luminance()

		expect(l).to.equal(0.8549926081242338)
	}) # }}}

	it('readable(#abc, #963)', func() { # {{{
		expect(Color.from('#abc').readable(Color.from('#963')!!)).to.equal(false)
	}) # }}}

	it('readable(#963, #fff)', func() { # {{{
		expect(Color.from('#963').readable(Color.from('#fff')!!)).to.equal(true)
	}) # }}}

	it('readable(#963, #fff, true)', func() { # {{{
		expect(Color.from('#963').readable(Color.from('#fff')!!, true)).to.equal(false)
	}) # }}}

	it('readable(#555, #fff, true)', func() { # {{{
		expect(Color.from('#555').readable(Color.from('#fff')!!, true)).to.equal(true)
	}) # }}}
})

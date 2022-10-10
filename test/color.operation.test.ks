#![bin]

extern {
	describe:	func
	it:			func
}

import {
	'chai' for expect
	'./fixtures/compile/color.ks'
}

describe('color.operation', func() {
	it('blend(#ff0, blue, 0.5)', func() { # {{{
		var c = new Color('#ff0').blend(Color.from('blue')!!, 0.5)

		expect(c.hex()).to.equal('#808080')
	}) # }}}

	it('blend(#ff0, blue, 0.5, rgb)', func() { # {{{
		var c = new Color('#ff0').blend(Color.from('blue')!!, 0.5, Space::RGB)

		expect(c.hex()).to.equal('#808080')
	}) # }}}

	it('clearer(#ff08, 0.5)', func() { # {{{
		var c = new Color('#ff08').clearer(0.5)

		expect(c.hex()).to.equal('#ffff0008')
	}) # }}}

	it('clearer(#ff08, 50%)', func() { # {{{
		var c = new Color('#ff08').clearer('50%')

		expect(c.hex()).to.equal('#ff04')
	}) # }}}

	it('opaquer(#ff08, 0.5)', func() { # {{{
		var c = new Color('#ff08').opaquer(0.5)

		expect(c.hex()).to.equal('#ff0')
	}) # }}}

	it('opaquer(#ff08, 50%)', func() { # {{{
		var c = new Color('#ff08').opaquer('50%')

		expect(c.hex()).to.equal('#ff0c')
	}) # }}}

	it('greyscale(#abc)', func() { # {{{
		var c = new Color('#abc').greyscale()

		expect(c.hex()).to.equal('#b9b9b9')
	}) # }}}

	it('greyscale(#abc, BT709)', func() { # {{{
		var c = new Color('#abc').greyscale('BT709')

		expect(c.hex()).to.equal('#b9b9b9')
	}) # }}}

	it('greyscale(#abc, average)', func() { # {{{
		var c = new Color('#abc').greyscale('average')

		expect(c.hex()).to.equal('#bbb')
	}) # }}}

	it('greyscale(#abc, lightness)', func() { # {{{
		var c = new Color('#abc').greyscale('lightness')

		expect(c.hex()).to.equal('#7d7d7d')
	}) # }}}

	it('greyscale(#abc, Y)', func() { # {{{
		var c = new Color('#abc').greyscale('Y')

		expect(c.hex()).to.equal('#b8b8b8')
	}) # }}}

	it('greyscale(#abc, RMY)', func() { # {{{
		var c = new Color('#abc').greyscale('RMY')

		expect(c.hex()).to.equal('#b4b4b4')
	}) # }}}

	it('negative(#abc)', func() { # {{{
		var c = new Color('#abc').negative()

		expect(c.hex()).to.equal('#543')
	}) # }}}

	it('scheme(#abc)', func() { # {{{
		var colors = new Color('#abc').scheme([
			func(color) {
				return color.shade(0.3).hex()
			},
			func(color) {
				return color.hex()
			}
		])

		expect(colors.length).to.equal(2)
		expect(colors[0]).to.equal('#77838f')
		expect(colors[1]).to.equal('#abc')
	}) # }}}

	it('shade(#abc, 0.5)', func() { # {{{
		var c = new Color('#abc').shade(0.5)

		expect(c.hex()).to.equal('#555e66')
	}) # }}}

	it('tint(#abc, 0.5)', func() { # {{{
		var c = new Color('#abc').tint(0.5)

		expect(c.hex()).to.equal('#d5dde6')
	}) # }}}

	it('tone(#abc, 0.5)', func() { # {{{
		var c = new Color('#abc').tone(0.5)

		expect(c.hex()).to.equal('#959ea6')
	}) # }}}

	it('gradient(#abc, #963, 4)', func() { # {{{
		var colors = new Color('#abc').gradient(Color.from('#963')!!, 4)

		expect(colors.length).to.equal(6)
		expect(colors[0].hex()).to.equal('#abc')
		expect(colors[1].hex()).to.equal('#a7aaad')
		expect(colors[2].hex()).to.equal('#a3998f')
		expect(colors[3].hex()).to.equal('#a08870')
		expect(colors[4].hex()).to.equal('#9c7752')
		expect(colors[5].hex()).to.equal('#963')
	}) # }}}
})

import '../color.ks'

Color.registerSpace({
	name: 'rvb',
	converters: {
		from: {
			srgb(red, green, blue, that) { # {{{
				that._rouge = red
				that._vert = green
				that._blue = blue
			} # }}}
		},
		to: {
			srgb(rouge, vert, blue, that) { # {{{
				that._red = rouge
				that._green = vert
				that._blue = blue
			} # }}}
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

export Color
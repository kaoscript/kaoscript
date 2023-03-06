#![rules(ignore-misfit)]
#![error(off)]

extern console

import {
	'./_/_array.ks'
	'./_/_float.ks'
	'./_/_integer.ks'
	'./_/_math.ks'
	'./_/_number.ks'
	'./_/_string.ks'
}

type float = Number
type int = Number

var $spaces = {}
var $aliases = {}
var $components = {}
var $formatters = {}

var $names = { # {{{
	'aliceblue': 'f0f8ff'
	'antiquewhite': 'faebd7'
	'aqua': '0ff'
	'aquamarine': '7fffd4'
	'azure': 'f0ffff'
	'beige': 'f5f5dc'
	'bisque': 'ffe4c4'
	'black': '000'
	'blanchedalmond': 'ffebcd'
	'blue': '00f'
	'blueviolet': '8a2be2'
	'brown': 'a52a2a'
	'burlywood': 'deb887'
	'burntsienna': 'ea7e5d'
	'cadetblue': '5f9ea0'
	'chartreuse': '7fff00'
	'chocolate': 'd2691e'
	'coral': 'ff7f50'
	'cornflowerblue': '6495ed'
	'cornsilk': 'fff8dc'
	'crimson': 'dc143c'
	'cyan': '0ff'
	'darkblue': '00008b'
	'darkcyan': '008b8b'
	'darkgoldenrod': 'b8860b'
	'darkgray': 'a9a9a9'
	'darkgreen': '006400'
	'darkgrey': 'a9a9a9'
	'darkkhaki': 'bdb76b'
	'darkmagenta': '8b008b'
	'darkolivegreen': '556b2f'
	'darkorange': 'ff8c00'
	'darkorchid': '9932cc'
	'darkred': '8b0000'
	'darksalmon': 'e9967a'
	'darkseagreen': '8fbc8f'
	'darkslateblue': '483d8b'
	'darkslategray': '2f4f4f'
	'darkslategrey': '2f4f4f'
	'darkturquoise': '00ced1'
	'darkviolet': '9400d3'
	'deeppink': 'ff1493'
	'deepskyblue': '00bfff'
	'dimgray': '696969'
	'dimgrey': '696969'
	'dodgerblue': '1e90ff'
	'firebrick': 'b22222'
	'floralwhite': 'fffaf0'
	'forestgreen': '228b22'
	'fuchsia': 'f0f'
	'gainsboro': 'dcdcdc'
	'ghostwhite': 'f8f8ff'
	'gold': 'ffd700'
	'goldenrod': 'daa520'
	'gray': '808080'
	'green': '008000'
	'greenyellow': 'adff2f'
	'grey': '808080'
	'honeydew': 'f0fff0'
	'hotpink': 'ff69b4'
	'indianred': 'cd5c5c'
	'indigo': '4b0082'
	'ivory': 'fffff0'
	'khaki': 'f0e68c'
	'lavender': 'e6e6fa'
	'lavenderblush': 'fff0f5'
	'lawngreen': '7cfc00'
	'lemonchiffon': 'fffacd'
	'lightblue': 'add8e6'
	'lightcoral': 'f08080'
	'lightcyan': 'e0ffff'
	'lightgoldenrodyellow': 'fafad2'
	'lightgray': 'd3d3d3'
	'lightgreen': '90ee90'
	'lightgrey': 'd3d3d3'
	'lightpink': 'ffb6c1'
	'lightsalmon': 'ffa07a'
	'lightseagreen': '20b2aa'
	'lightskyblue': '87cefa'
	'lightslategray': '789'
	'lightslategrey': '789'
	'lightsteelblue': 'b0c4de'
	'lightyellow': 'ffffe0'
	'lime': '0f0'
	'limegreen': '32cd32'
	'linen': 'faf0e6'
	'magenta': 'f0f'
	'maroon': '800000'
	'mediumaquamarine': '66cdaa'
	'mediumblue': '0000cd'
	'mediumorchid': 'ba55d3'
	'mediumpurple': '9370db'
	'mediumseagreen': '3cb371'
	'mediumslateblue': '7b68ee'
	'mediumspringgreen': '00fa9a'
	'mediumturquoise': '48d1cc'
	'mediumvioletred': 'c71585'
	'midnightblue': '191970'
	'mintcream': 'f5fffa'
	'mistyrose': 'ffe4e1'
	'moccasin': 'ffe4b5'
	'navajowhite': 'ffdead'
	'navy': '000080'
	'oldlace': 'fdf5e6'
	'olive': '808000'
	'olivedrab': '6b8e23'
	'orange': 'ffa500'
	'orangered': 'ff4500'
	'orchid': 'da70d6'
	'palegoldenrod': 'eee8aa'
	'palegreen': '98fb98'
	'paleturquoise': 'afeeee'
	'palevioletred': 'db7093'
	'papayawhip': 'ffefd5'
	'peachpuff': 'ffdab9'
	'peru': 'cd853f'
	'pink': 'ffc0cb'
	'plum': 'dda0dd'
	'powderblue': 'b0e0e6'
	'purple': '800080'
	'red': 'f00'
	'rosybrown': 'bc8f8f'
	'royalblue': '4169e1'
	'saddlebrown': '8b4513'
	'salmon': 'fa8072'
	'sandybrown': 'f4a460'
	'seagreen': '2e8b57'
	'seashell': 'fff5ee'
	'sienna': 'a0522d'
	'silver': 'c0c0c0'
	'skyblue': '87ceeb'
	'slateblue': '6a5acd'
	'slategray': '708090'
	'slategrey': '708090'
	'snow': 'fffafa'
	'springgreen': '00ff7f'
	'steelblue': '4682b4'
	'tan': 'd2b48c'
	'teal': '008080'
	'thistle': 'd8bfd8'
	'tomato': 'ff6347'
	'turquoise': '40e0d0'
	'violet': 'ee82ee'
	'wheat': 'f5deb3'
	'white': 'fff'
	'whitesmoke': 'f5f5f5'
	'yellow': 'ff0'
	'yellowgreen': '9acd32'
} # }}}

func $blend(x: float, y: float, percentage: float): float { # {{{
	return (1 - percentage) * x + percentage * y
} # }}}

func $binder(last: func, components, first: func, ...firstArgs): func { # {{{
	var that = first(...firstArgs)

	var lastArgs = [that[component.field] for component, name of components]

	lastArgs.push(that)

	return last(...lastArgs)
} # }}}

namespace $caster {
	func alpha(n? = null, percentage: bool = false): float { # {{{
		var mut i: Number = Float.parse(n)

		return i == NaN ? 1 : (percentage ? i / 100 : i).limit(0, 1).round(3)
	} # }}}

	func ff(n): int { # {{{
		return Float.parse(n).limit(0, 255).round()
	} # }}}

	func percentage(n): float { # {{{
		return Float.parse(n).limit(0, 100).round(1)
	} # }}}

	export *
}

func $component(component, name: string, space: string): void { # {{{
	component.field = '_' + name

	$spaces[space].components[name] = component

	$components[name] ??= {
		field: component.field
		spaces: {}
		families: []
	}

	$components[name].families.push(space)
	$components[name].spaces[space] = true
} # }}}

func $convert(that: Color, space: string, result: Color | object = {_alpha: 0}): Color | object ~ Error { # {{{
	if ?(s = $spaces[that._space]).converters[space] {
		var args = [that[component.field] for component, name of s.components]

		args.push(result)

		s.converters[space](...args)

		result._space = Space(space)!?

		return result
	}
	else {
		throw new Error(`It can't convert a color from '\(that._space)' to '\(space)' spaces.`)
	}
} # }}}

func $find(from: string, to: string): void { # {{{
	for var _, name of $spaces[from].converters {
		if ?$spaces[name].converters[to] {
			$spaces[from].converters[to] = $binder^^($spaces[name].converters[to], $spaces[name].components, $spaces[from].converters[name], ...)

			return
		}
	}
} # }}}

func $from(that: Color, args: array): Color { # {{{
	that._dummy = false

	if args.length == 0 {
		return that
	}
	else if args[0] is string && ?$parsers[args[0]] {
		return that if $parsers[args.shift()](that, args)
	}
	else {
		for parse, name of $parsers {
			return that if parse(that, args)
		}
	}

	that._dummy = true

	return that
} # }}}

func $hex(that: Color) { # {{{
	var chars = '0123456789abcdef'

	var r1 = that._red >> 4
	var g1 = that._green >> 4
	var b1 = that._blue >> 4

	var r2 = that._red && 0xf
	var g2 = that._green && 0xf
	var b2 = that._blue && 0xf

	if that._alpha == 1 {
		if ((r1 ^^ r2) || (g1 ^^ g2) || (b1 ^^ b2)) == 0 {
			return '#' + chars.charAt(r1) + chars.charAt(g1) + chars.charAt(b1)
		}

		return '#' + chars.charAt(r1) + chars.charAt(r2) + chars.charAt(g1) + chars.charAt(g2) + chars.charAt(b1) + chars.charAt(b2)
	}
	else {
		var mut a = Math.round(that._alpha * 255)
		var mut a1 = a >> 4
		var mut a2 = a && 0xf

		if ((r1 ^^ r2) || (g1 ^^ g2) || (b1 ^^ b2) || (a1 ^^ a2)) == 0 {
			return '#' + chars.charAt(r1) + chars.charAt(g1) + chars.charAt(b1) + chars.charAt(a1)
		}

		return '#' + chars.charAt(r1) + chars.charAt(r2) + chars.charAt(g1) + chars.charAt(g2) + chars.charAt(b1) + chars.charAt(b2) + chars.charAt(a1) + chars.charAt(a2)
	}
} # }}}

var $parsers = {
	srgb(that: Color, args: array): bool { # {{{
		if args.length == 1 {
			if args[0] is number {
				that._space = Space.SRGB
				that._alpha = $caster.alpha(((args[0] >> 24) && 0xff) / 255)
				that._red = (args[0] >> 16) && 0xff
				that._green = (args[0] >> 8) && 0xff
				that._blue = args[0] && 0xff
				return true
			}
			else if args[0] is array {
				that._space = Space.SRGB

				that._alpha = args[0].length == 4 ? $caster.alpha(args[0][3]) : 1
				that._red = $caster.ff(args[0][0])
				that._green = $caster.ff(args[0][1])
				that._blue = $caster.ff(args[0][2])
				return true
			}
			else if args[0] is object {
				if ?args[0].r && ?args[0].g && ?args[0].b {
					that._space = Space.SRGB
					that._alpha = $caster.alpha(args[0].a)
					that._red = $caster.ff(args[0].r)
					that._green = $caster.ff(args[0].g)
					that._blue = $caster.ff(args[0].b)
					return true
				}

				if ?args[0].red && ?args[0].green && ?args[0].blue {
					that._space = Space.SRGB
					that._alpha = $caster.alpha(args[0].alpha)
					that._red = $caster.ff(args[0].red)
					that._green = $caster.ff(args[0].green)
					that._blue = $caster.ff(args[0].blue)
					return true
				}
			}
			else if args[0] is string {
				var mut color = (args[0] as string).lower().replace(/[^a-z0-9,.()#%]/g, '')

				if 'transparent' == color {
					that._alpha = that._red = that._green = that._blue = 0
					return true
				}

				else if 'rand' == color {
					var c = Math.random() * 0xffffff || 0

					that._space = Space.SRGB
					that._alpha = 1
					that._red = ((c >> 16) && 0xff)
					that._green = ((c >> 8) && 0xff)
					that._blue = (c && 0xff)
					return true
				}

				if ?$names[color] {
					color = '#' + $names[color]
				}

				// #ff0000aa
				if match ?= /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color) {
					that._space = Space.SRGB
					that._red = Integer.parse(match[1], 16)
					that._green = Integer.parse(match[2], 16)
					that._blue = Integer.parse(match[3], 16)
					that._alpha = $caster.alpha(Integer.parse(match[4], 16) / 255)
					return true
				}
				// #ff9000, #ff0000
				else if match ?= /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color) {
					that._space = Space.SRGB
					that._red = Integer.parse(match[1], 16)
					that._green = Integer.parse(match[2], 16)
					that._blue = Integer.parse(match[3], 16)
					that._alpha = 1
					return true
				}
				// #fffa
				else if match ?= /^#?([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color) {
					that._space = Space.SRGB
					that._red = Integer.parse(match[1] + match[1], 16)
					that._green = Integer.parse(match[2] + match[2], 16)
					that._blue = Integer.parse(match[3] + match[3], 16)
					that._alpha = $caster.alpha(Integer.parse(match[4] + match[4], 16) / 255)
					return true
				}
				// #f00, #fff
				else if match ?= /^#?([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color) {
					that._space = Space.SRGB
					that._red = Integer.parse(match[1] + match[1], 16)
					that._green = Integer.parse(match[2] + match[2], 16)
					that._blue = Integer.parse(match[3] + match[3], 16)
					that._alpha = 1
					return true
				}
				// rgb(1, 234, 56)
				else if match ?= /^rgba?\((\d{1,3}),(\d{1,3}),(\d{1,3})(,([0-9.]+)(\%)?)?\)$/.exec(color) {
					that._space = Space.SRGB
					that._red = $caster.ff(match[1])
					that._green = $caster.ff(match[2])
					that._blue = $caster.ff(match[3])
					that._alpha = $caster.alpha(match[5], ?match[6])
					return true
				}
				// rgb(66%, 55%, 44%) in [0,100]%, [0,100]%, [0,100]%
				else if match ?= /^rgba?\(([0-9.]+\%),([0-9.]+\%),([0-9.]+\%)(,([0-9.]+)(\%)?)?\)$/.exec(color) {
					that._space = Space.SRGB
					that._red = Math.round(2.55 * $caster.percentage(match[1]))
					that._green = Math.round(2.55 * $caster.percentage(match[2]))
					that._blue = Math.round(2.55 * $caster.percentage(match[3]))
					that._alpha = $caster.alpha(match[5], ?match[6])
					return true
				}
				// rgba(#ff0000, 1)
				else if match ?= /^rgba?\(#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2}),([0-9.]+)(\%)?\)$/.exec(color) {
					that._space = Space.SRGB
					that._red = Integer.parse(match[1], 16)
					that._green = Integer.parse(match[2], 16)
					that._blue = Integer.parse(match[3], 16)
					that._alpha = $caster.alpha(match[4], ?match[5])
					return true
				}
				// rgba(#f00, 1)
				else if match ?= /^rgba\(#?([0-9a-f])([0-9a-f])([0-9a-f]),([0-9.]+)(\%)?\)$/.exec(color) {
					that._space = Space.SRGB
					that._red = Integer.parse(match[1] + match[1], 16)
					that._green = Integer.parse(match[2] + match[2], 16)
					that._blue = Integer.parse(match[3] + match[3], 16)
					that._alpha = $caster.alpha(match[4], ?match[5])
					return true
				}
				// 1, 234, 56
				else if match ?= /^(\d{1,3}),(\d{1,3}),(\d{1,3})(?:,([0-9.]+))?$/.exec(color) {
					that._space = Space.SRGB
					that._red = $caster.ff(match[1])
					that._green = $caster.ff(match[2])
					that._blue = $caster.ff(match[3])
					that._alpha = $caster.alpha(match[4])
					return true
				}
			}
		}
		else if args.length >= 3 {
			that._space = Space.SRGB
			that._alpha = args.length >= 4 ? $caster.alpha(args[3]) : 1
			that._red = $caster.ff(args[0])
			that._green = $caster.ff(args[1])
			that._blue = $caster.ff(args[2])
			return true
		}

		return false
	} # }}}
	gray(that: Color, args: array): bool { # {{{
		if args.length >= 1 {
			if Number.isFinite(Float.parse(args[0])) {
				that._space = Space.SRGB
				that._red = that._green = that._blue = $caster.ff(args[0])
				that._alpha = args.length >= 2 ? $caster.alpha(args[1]) : 1
				return true
			}
			else if args[0] is string {
				var color = (args[0] as string).lower().replace(/[^a-z0-9,.()#%]/g, '')

				// gray(56)
				if match ?= /^gray\((\d{1,3})(?:,([0-9.]+)(\%)?)?\)$/.exec(color) {
					that._space = Space.SRGB
					that._red = that._green = that._blue = $caster.ff(match[1])
					that._alpha = $caster.alpha(match[2], ?match[3])
					return true
				}
				// gray(66%)
				else if match ?= /^gray\(([0-9.]+\%)(?:,([0-9.]+)(\%)?)?\)$/.exec(color) {
					that._space = Space.SRGB
					that._red = that._green = that._blue = Math.round(2.55 * $caster.percentage(match[1]))
					that._alpha = $caster.alpha(match[2], ?match[3])
					return true
				}
			}
		}

		return false
	} # }}}
}

func $space(name: string): void { # {{{
	$spaces[name] = $spaces[name] ?? {
		alias: {}
		converters: {}
		components: {}
	}
} # }}}

export enum Space<string> {
}

export class Color {
	private {
		_dummy: bool = false
		_space: Space = Space.SRGB
		_alpha: int = 0
		_red: int = 0
		_green: int = 0
		_blue: int = 0
	}

	macro registerSpace(@space: Object) {
		var spaces: Array = [space.name.toUpperCase()]

		if ?space.alias {
			for var name in space.alias {
				spaces.push(name.toUpperCase())
			}
		}

		macro {
			impl Space {
				#s(spaces)
			}
		}

		if ?space.components {
			var fields: Array = []
			var methods: Array = []

			for var component, name of space.components {
				var field = `_\(name)`

				fields.push(macro private #w(field): Number = 0)

				methods.push(macro {
					override #w(name)() => this.getField(#(name))
					override #w(name)(value) => this.setField(#(name), value)
				})
			}

			macro {
				#![rules(dont-assert-override)]

				Color.addSpace(#(space))

				impl Color {
					#s(fields)
					#s(methods)
				}
			}
		}
		else {
			macro Color.addSpace(#(space))
		}
	}

	static {
		addSpace(space: Object) { # {{{
			var spaces = Object.keys($spaces)

			$space(space.name)

			if ?space.parser {
				$parsers[space.name] = space.parser
			}

			if ?space.formatter {
				$formatters[space.name] = {
					space: space.name,
					formatter: space.formatter
				}
			}
			else if ?space.formatters {
				for formatter, name of space.formatters {
					$formatters[name] = {
						space: space.name,
						formatter: formatter
					}
				}
			}

			if ?space.alias {
				for alias in space.alias {
					$spaces[space.name].alias[alias] = true
					$aliases[alias] = Space(space.name)
				}

				if ?$parsers[space.name] {
					for alias in space.alias {
						$parsers[alias] = $parsers[space.name]
					}
				}

				if ?$formatters[space.name] {
					for alias in space.alias {
						$formatters[alias] = $formatters[space.name]
					}
				}
			}

			if ?space.converters {
				if ?space.converters.from {
					for converter, name of space.converters.from {
						$space(name) if !?$spaces[name]

						$spaces[name].converters[space.name] = converter
					}
				}
				if ?space.converters.to {
					for converter, name of space.converters.to {
						$spaces[space.name].converters[name] = converter
					}
				}
			}

			for name in spaces {
				if !?$spaces[name].converters[space.name] {
					$find(name, space.name)
				}

				if !?$spaces[space.name].converters[name] {
					$find(space.name, name)
				}
			}

			if ?space.components {
				for component, name of space.components {
					if ?component.family {
						$spaces[space.name].components[name] = $spaces[component.family].components[name]

						$components[name].spaces[space.name] = true
					}
					else if ?component.mutator {
						$component(component, name, space.name)
					}
					else {
						component.min ??= 0
						component.round ??= 0
						if !?component.loop || component.min != 0 {
							component.loop = false
						}
						else if component.loop {
							component.mod = component.max + 1
							component.half = component.mod / 2
						}

						$component(component, name, space.name)
					}
				}
			}
			//console.log($spaces[space.name])
			//console.log($components)
		} # }}}

		from(...args): Color | bool { # {{{
			var color = $from(new Color(), args)

			return color._dummy ? false : color
		} # }}}

		greyscale(...args): Color | bool { # {{{
			var mut model = args.last()
			if model == 'BT709' || model == 'average' || model == 'lightness' || model == 'Y' || model == 'RMY' {
				args.pop()
			}
			else {
				model = null
			}

			var color = $from(new Color(), args)

			return color._dummy ? false : color.greyscale(model)
		} # }}}

		hex(...args): String | bool { # {{{
			var color = $from(new Color(), args)

			return color._dummy ? false : color.hex()
		} # }}}

		negative(...args): Color | bool { # {{{
			var color = $from(new Color(), args)

			return color._dummy ? false : color.negative()
		} # }}}

		registerFormatter(format: string, formatter: func): void { # {{{
			$formatters[format] = {
				formatter: formatter
			}
		} # }}}

		registerParser(format: string, parser: func): void { # {{{
			$parsers[format] = parser
		} # }}}
	}

	constructor(...args) { # {{{
		$from(this, args)
	} # }}}

	alpha(): int => this._alpha

	alpha(value: string | number): Color { # {{{
		this._alpha = $caster.alpha(value)

		return this
	} # }}}

	blend(mut color: Color, mut percentage: float, mut space: Space = Space.SRGB, alpha: bool = false): Color { # {{{
		if alpha {
			var w = (percentage * 2) - 1
			var a = color._alpha - this._alpha

			this._alpha = $blend(this._alpha, color._alpha, percentage).round(2)
			if w * a == -1 {
				percentage = w
			}
			else {
				percentage = (w + a) / (1 + (w * a))
			}
		}

		space = $aliases[space] ?? space

		this.space(space)
		color = color.like(space)

		var components = $spaces[space].components

		for component, name of components {
			if component.loop {
				var mut d: Number = Math.abs(this[component.field] - color[component.field])

				if d > component.half {
					d = component.mod:!Number - d
				}

				this[component.field] = ((this[component.field]:!Number + (d * percentage)) % component.mod).round(component.round)
			}
			else {
				this[component.field] = $blend(this[component.field], color[component.field], percentage).limit(component.min, component.max).round(component.round)
			}
		}

		return this
	} # }}}

	clearer(value: string | number): Color { # {{{
		if value is String && value.endsWith('%') {
			return this.alpha(this._alpha * ((100 - value.toFloat()) / 100))
		}
		else {
			return this.alpha(this._alpha - value.toFloat())
		}
	} # }}}

	clone(): Color { # {{{
		return this.copy(new Color())
	} # }}}

	contrast(mut color: Color) { # {{{
		var a = this._alpha

		if a == 1 {
			if color._alpha != 1 {
				color = color.clone().blend(this, 0.5, Space.SRGB, true)
			}

			var l1 = this.luminance() + 0.05
			var l2 = color.luminance() + 0.05

			var mut ratio = l1 / l2
			if l2 > l1 {
				ratio = 1 / ratio
			}

			ratio = ratio.round(2)

			return {
				ratio: ratio
				error: 0
				min: ratio
				max: ratio
			}
		}
		else {
			var black = this.clone().blend($static.black, 0.5, Space.SRGB, true).contrast(color).ratio
			var white = this.clone().blend($static.white, 0.5, Space.SRGB, true).contrast(color).ratio

			var max = Math.max(black, white)

			var closest = new Color(
				((color._red - (this._red * a)) / (1 - a)).limit(0, 255),
				((color._green - (this._green * a)) / (1 - a)).limit(0, 255),
				((color._blue - (this._blue * a)) / (1 - a)).limit(0, 255)
			)

			var min: Number = this.clone().blend(closest, 0.5, Space.SRGB, true).contrast(color).ratio

			return {
				ratio: ((min + max) / 2).round(2)
				error: ((max - min) / 2).round(2)
				min: min
				max: max
			}
		}
	} # }}}

	copy(target: Color): Color { # {{{
		var s1 = this._space
		var s2 = target._space

		this.space(Space.SRGB)
		target.space(Space.SRGB)

		target._red = this._red
		target._green = this._green
		target._blue = this._blue
		target._alpha = this._alpha
		target._dummy = this._dummy

		this.space(s1)
		target.space(s2)

		return target
	} # }}}

	distance(mut color: Color): float { # {{{
		var that: {_red: float, _green: float, _blue: float} = this.like(Space.SRGB)
		color = color.like(Space.SRGB)

		return Math.sqrt(3 * (color._red - that._red) * (color._red - that._red) + 4 * (color._green - that._green) * (color._green - that._green) + 2 * (color._blue - that._blue) * (color._blue - that._blue))
	} # }}}

	equals(color: Color): bool { # {{{
		return this.hex() == color.hex()
	} # }}}

	format(format: string = this._space) { # {{{
		if var format ?= $formatters[format] {
			return format.formatter(?format.space ? this.like(format.space) : this)
		}
		else {
			return false
		}
	} # }}}

	from(...args): Color { # {{{
		return $from(this, args)
	} # }}}

	private getField(name) { # {{{
		var component = $components[name]

		if ?component.spaces[this._space] {
			return this[component.field]
		}
		else if component.families.length > 1 {
			throw new Error(`The component '\(name)' has a conflict between the spaces '\(component.families.join('\', \''))'`)
		}
		else {
			return this.like(component.families[0])[component.field]
		}
	} # }}}

	gradient(endColor: Color, mut length: int): array<Color> { # {{{
		var gradient: array<Color> = [this]

		if length > 0 {
			this.space(Space.SRGB)
			endColor.space(Space.SRGB)

			length += 1

			var red = endColor._red - this._red
			var green = endColor._green - this._green
			var blue = endColor._blue - this._blue

			for var i from 1 to~ length {
				var offset = i / length

				var color = this.clone()
				color._red += Math.round(red * offset)
				color._green += Math.round(green * offset)
				color._blue += Math.round(blue * offset)
				gradient.push(color)
			}
		}

		gradient.push(endColor)

		return gradient
	} # }}}

	greyscale(model: string = 'BT709'): Color { # {{{
		this.space(Space.SRGB)

		if model == 'BT709' {
			this._red = this._green = this._blue = Math.round(0.2126 * this._red + 0.7152 * this._green + 0.0722 * this._blue)
		}
		else if model == 'average' {
			this._red = this._green = this._blue = Math.round((this._red + this._green + this._blue) / 3)
		}
		else if model == 'lightness' {
			this._red = this._green = this._blue = Math.round((Math.max(this._red, this._green, this._blue) + Math.min(this._red, this._green, this._blue)) / 3)
		}
		else if model == 'Y' {
			this._red = this._green = this._blue = Math.round(0.299 * this._red + 0.587 * this._green + 0.114 * this._blue)
		}
		else if model == 'RMY' {
			this._red = this._green = this._blue = Math.round(0.5 * this._red + 0.419 * this._green + 0.081 * this._blue)
		}

		return this
	} # }}}

	hex(): string { # {{{
		return $hex(this.like(Space.SRGB))
	} # }}}

	isBlack(): bool { # {{{
		var that = this.like(Space.SRGB)
		return that._red == 0 && that._green == 0 && that._blue == 0
	} # }}}

	isTransparent(): bool { # {{{
		if this._alpha == 0 {
			var that = this.like(Space.SRGB)
			return that._red == 0 && that._green == 0 && that._blue == 0
		}
		else {
			return false
		}
	} # }}}

	isWhite(): bool { # {{{
		var that = this.like(Space.SRGB)
		return that._red == 255 && that._green == 255 && that._blue == 255
	} # }}}

	like(mut space: string) { # {{{
		space = $aliases[space] ?? space

		if var value ?= Space(space) {
			if this._space != value && ?$spaces[this._space].converters[space] {
				return $convert(this, value)
			}
		}

		return this
	} # }}}

	luminance(): Number { # {{{
		var that = this.like(Space.SRGB)

		var mut r: float = that._red:!float / 255
		r = r < 0.03928 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4)

		var mut g: float = that._green:!float / 255
		g = g < 0.03928 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4)

		var mut b: float = that._blue:!float / 255
		b = b < 0.03928 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4)

		return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
	} # }}}

	negative(): Color { # {{{
		this.space(Space.SRGB)

		this._red ^^= 0xff
		this._green ^^= 0xff
		this._blue ^^= 0xff

		return this
	} # }}}

	opaquer(value: string | number): Color { # {{{
		if value is String && value.endsWith('%') {
			return this.alpha(this._alpha * ((100 + value.toFloat()) / 100))
		}
		else {
			return this.alpha(this._alpha + value.toFloat())
		}
	} # }}}

	readable(color: Color, tripleA: bool = false): bool { # {{{
		if tripleA {
			return this.contrast(color).ratio >= 7
		}
		else {
			return this.contrast(color).ratio >= 4.5
		}
	} # }}}

	scheme(functions: array<(color: Color)>): array { # {{{
		return [fn(this.clone()) for fn in functions]
	} # }}}

	private setField(name, value: number | string): Color { # {{{
		var mut component = $components[name]

		if ?component.spaces[this._space] {
			component = $spaces[this._space].components[name]
		}
		else if component.families.length > 1 {
			throw new Error(`The component '\(name)' has a conflict between the spaces '\(component.families.join('\', \''))'`)
		}
		else {
			this.space(component.families[0])

			component = $spaces[component.families[0]].components[name]
		}

		if ?component.parser {
			this[component.field] = component.parser(value)
		}
		else if component.loop {
			this[component.field] = value.toFloat().mod(component.mod).round(component.round)
		}
		else {
			this[component.field] = value.toFloat().limit(component.min, component.max).round(component.round)
		}

		return this
	} # }}}

	shade(percentage: float): Color { # {{{
		return this.blend($static.black, percentage)
	} # }}}

	space(): Space => this._space

	space(mut space: string): Color { # {{{
		space = $aliases[space] ?? space

		if !?$spaces[space] && ?$components[space] {
			if ?$spaces[this._space].components[space] {
				return this
			}
			else if $components[space].families.length == 1 {
				space = $components[space].families[0]
			}
			else {
				throw new Error(`The component '\(space)' has a conflict between the spaces '\($components[space].families.join('\', \''))'`)
			}
		}

		if var value ?= Space(space) {
			if this._space != value && ?$spaces[this._space].converters[space] {
				$convert(this, value, this)
			}
		}
		else {
			$convert(this, space, this)
		}

		return this
	} # }}}

	tint(percentage: float): Color { # {{{
		return this.blend($static.white, percentage)
	} # }}}

	tone(percentage: float): Color { # {{{
		return this.blend($static.gray, percentage)
	} # }}}
}

Color.registerSpace({
	name: 'srgb'
	alias: ['rgb']
	formatters: {
		hex(that: Color): string { # {{{
			return $hex(that)
		} # }}}
		srgb(that: Color): string { # {{{
			if that._alpha == 1 {
				return 'rgb(' + that._red + ', ' + that._green + ', ' + that._blue + ')'
			}
			else {
				return 'rgba(' + that._red + ', ' + that._green + ', ' + that._blue + ', ' + that._alpha + ')'
			}
		} # }}}
	}
	components: {
		red: {
			max: 255
		}
		green: {
			max: 255
		}
		blue: {
			max: 255
		}
	}
})

var $static = { # {{{
	black: Color.from('#000')
	gray: Color.from('#808080')
	white: Color.from('#fff')
} # }}}
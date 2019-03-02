require("kaoscript/register");
var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {Array, __ks_Array} = require("./_/_array.ks")();
	var Float = require("./_/_float.ks")().Float;
	var Integer = require("./_/_integer.ks")().Integer;
	var {Number, __ks_Number} = require("./_/_number.ks")();
	var {String, __ks_String} = require("./_/_string.ks")();
	let $spaces = {};
	let $aliases = {};
	let $components = {};
	let $formatters = {};
	const $names = {
		"aliceblue": "f0f8ff",
		"antiquewhite": "faebd7",
		"aqua": "0ff",
		"aquamarine": "7fffd4",
		"azure": "f0ffff",
		"beige": "f5f5dc",
		"bisque": "ffe4c4",
		"black": "000",
		"blanchedalmond": "ffebcd",
		"blue": "00f",
		"blueviolet": "8a2be2",
		"brown": "a52a2a",
		"burlywood": "deb887",
		"burntsienna": "ea7e5d",
		"cadetblue": "5f9ea0",
		"chartreuse": "7fff00",
		"chocolate": "d2691e",
		"coral": "ff7f50",
		"cornflowerblue": "6495ed",
		"cornsilk": "fff8dc",
		"crimson": "dc143c",
		"cyan": "0ff",
		"darkblue": "00008b",
		"darkcyan": "008b8b",
		"darkgoldenrod": "b8860b",
		"darkgray": "a9a9a9",
		"darkgreen": "006400",
		"darkgrey": "a9a9a9",
		"darkkhaki": "bdb76b",
		"darkmagenta": "8b008b",
		"darkolivegreen": "556b2f",
		"darkorange": "ff8c00",
		"darkorchid": "9932cc",
		"darkred": "8b0000",
		"darksalmon": "e9967a",
		"darkseagreen": "8fbc8f",
		"darkslateblue": "483d8b",
		"darkslategray": "2f4f4f",
		"darkslategrey": "2f4f4f",
		"darkturquoise": "00ced1",
		"darkviolet": "9400d3",
		"deeppink": "ff1493",
		"deepskyblue": "00bfff",
		"dimgray": "696969",
		"dimgrey": "696969",
		"dodgerblue": "1e90ff",
		"firebrick": "b22222",
		"floralwhite": "fffaf0",
		"forestgreen": "228b22",
		"fuchsia": "f0f",
		"gainsboro": "dcdcdc",
		"ghostwhite": "f8f8ff",
		"gold": "ffd700",
		"goldenrod": "daa520",
		"gray": "808080",
		"green": "008000",
		"greenyellow": "adff2f",
		"grey": "808080",
		"honeydew": "f0fff0",
		"hotpink": "ff69b4",
		"indianred": "cd5c5c",
		"indigo": "4b0082",
		"ivory": "fffff0",
		"khaki": "f0e68c",
		"lavender": "e6e6fa",
		"lavenderblush": "fff0f5",
		"lawngreen": "7cfc00",
		"lemonchiffon": "fffacd",
		"lightblue": "add8e6",
		"lightcoral": "f08080",
		"lightcyan": "e0ffff",
		"lightgoldenrodyellow": "fafad2",
		"lightgray": "d3d3d3",
		"lightgreen": "90ee90",
		"lightgrey": "d3d3d3",
		"lightpink": "ffb6c1",
		"lightsalmon": "ffa07a",
		"lightseagreen": "20b2aa",
		"lightskyblue": "87cefa",
		"lightslategray": "789",
		"lightslategrey": "789",
		"lightsteelblue": "b0c4de",
		"lightyellow": "ffffe0",
		"lime": "0f0",
		"limegreen": "32cd32",
		"linen": "faf0e6",
		"magenta": "f0f",
		"maroon": "800000",
		"mediumaquamarine": "66cdaa",
		"mediumblue": "0000cd",
		"mediumorchid": "ba55d3",
		"mediumpurple": "9370db",
		"mediumseagreen": "3cb371",
		"mediumslateblue": "7b68ee",
		"mediumspringgreen": "00fa9a",
		"mediumturquoise": "48d1cc",
		"mediumvioletred": "c71585",
		"midnightblue": "191970",
		"mintcream": "f5fffa",
		"mistyrose": "ffe4e1",
		"moccasin": "ffe4b5",
		"navajowhite": "ffdead",
		"navy": "000080",
		"oldlace": "fdf5e6",
		"olive": "808000",
		"olivedrab": "6b8e23",
		"orange": "ffa500",
		"orangered": "ff4500",
		"orchid": "da70d6",
		"palegoldenrod": "eee8aa",
		"palegreen": "98fb98",
		"paleturquoise": "afeeee",
		"palevioletred": "db7093",
		"papayawhip": "ffefd5",
		"peachpuff": "ffdab9",
		"peru": "cd853f",
		"pink": "ffc0cb",
		"plum": "dda0dd",
		"powderblue": "b0e0e6",
		"purple": "800080",
		"red": "f00",
		"rosybrown": "bc8f8f",
		"royalblue": "4169e1",
		"saddlebrown": "8b4513",
		"salmon": "fa8072",
		"sandybrown": "f4a460",
		"seagreen": "2e8b57",
		"seashell": "fff5ee",
		"sienna": "a0522d",
		"silver": "c0c0c0",
		"skyblue": "87ceeb",
		"slateblue": "6a5acd",
		"slategray": "708090",
		"slategrey": "708090",
		"snow": "fffafa",
		"springgreen": "00ff7f",
		"steelblue": "4682b4",
		"tan": "d2b48c",
		"teal": "008080",
		"thistle": "d8bfd8",
		"tomato": "ff6347",
		"turquoise": "40e0d0",
		"violet": "ee82ee",
		"wheat": "f5deb3",
		"white": "fff",
		"whitesmoke": "f5f5f5",
		"yellow": "ff0",
		"yellowgreen": "9acd32"
	};
	function $blend(x, y, percentage) {
		if(arguments.length < 3) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'float'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isNumber(y)) {
			throw new TypeError("'y' is not of type 'float'");
		}
		if(percentage === void 0 || percentage === null) {
			throw new TypeError("'percentage' is not nullable");
		}
		else if(!Type.isNumber(percentage)) {
			throw new TypeError("'percentage' is not of type 'float'");
		}
		return ((1 - percentage) * x) + (percentage * y);
	}
	function $binder(last, components, first, ...firstArgs) {
		if(arguments.length < 3) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(last === void 0 || last === null) {
			throw new TypeError("'last' is not nullable");
		}
		else if(!Type.isFunction(last)) {
			throw new TypeError("'last' is not of type 'Function'");
		}
		if(components === void 0 || components === null) {
			throw new TypeError("'components' is not nullable");
		}
		if(first === void 0 || first === null) {
			throw new TypeError("'first' is not nullable");
		}
		else if(!Type.isFunction(first)) {
			throw new TypeError("'first' is not of type 'Function'");
		}
		let that = first.call(null, ...firstArgs);
		let lastArgs = Helper.mapObject(components, function(name, component) {
			return that[component.field];
		});
		lastArgs.push(that);
		return last.call(null, ...lastArgs);
	}
	let $caster = {
		alpha(n = null, percentage) {
			if(percentage === void 0 || percentage === null) {
				percentage = false;
			}
			let i = Float.parse(n);
			return isNaN(i) ? 1 : __ks_Number._im_round(__ks_Number._im_limit(percentage ? i / 100 : i, 0, 1), 3);
		},
		ff(n) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(n === void 0 || n === null) {
				throw new TypeError("'n' is not nullable");
			}
			return __ks_Number._im_round(__ks_Number._im_limit(Float.parse(n), 0, 255));
		},
		percentage(n) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(n === void 0 || n === null) {
				throw new TypeError("'n' is not nullable");
			}
			return __ks_Number._im_round(__ks_Number._im_limit(Float.parse(n), 0, 100), 1);
		}
	};
	function $component(component, name, space) {
		if(arguments.length < 3) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(component === void 0 || component === null) {
			throw new TypeError("'component' is not nullable");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		else if(!Type.isString(name)) {
			throw new TypeError("'name' is not of type 'String'");
		}
		if(space === void 0 || space === null) {
			throw new TypeError("'space' is not nullable");
		}
		else if(!Type.isString(space)) {
			throw new TypeError("'space' is not of type 'String'");
		}
		component.field = "_" + name;
		$spaces[space].components[name] = component;
		if(!Type.isValue($components[name])) {
			$components[name] = {
				field: component.field,
				spaces: {},
				families: []
			};
		}
		$components[name].families.push(space);
		$components[name].spaces[space] = true;
	}
	function $convert() {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		let __ks_i = -1;
		let that = arguments[++__ks_i];
		if(that === void 0 || that === null) {
			throw new TypeError("'that' is not nullable");
		}
		else if(!Type.is(that, Color)) {
			throw new TypeError("'that' is not of type 'Color'");
		}
		let space = arguments[++__ks_i];
		if(space === void 0 || space === null) {
			throw new TypeError("'space' is not nullable");
		}
		else if(!Type.isString(space)) {
			throw new TypeError("'space' is not of type 'String'");
		}
		let __ks__;
		let result = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : {
			_alpha: 0
		};
		let s;
		if(Type.isValue((s = $spaces[that._space]).converters[space])) {
			let args = Helper.mapObject(s.components, function(name, component) {
				return that[component.field];
			});
			args.push(result);
			s.converters[space](...args);
			result._space = space;
			return result;
		}
		else {
			throw new Error("It can't convert a color from '" + that._space + "' to '" + space + "' spaces.");
		}
	}
	function $find(from, to) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(from === void 0 || from === null) {
			throw new TypeError("'from' is not nullable");
		}
		else if(!Type.isString(from)) {
			throw new TypeError("'from' is not of type 'String'");
		}
		if(to === void 0 || to === null) {
			throw new TypeError("'to' is not nullable");
		}
		else if(!Type.isString(to)) {
			throw new TypeError("'to' is not of type 'String'");
		}
		for(let name in $spaces[from].converters) {
			if($spaces[name].converters[to]) {
				$spaces[from].converters[to] = Helper.vcurry($binder, null, $spaces[name].converters[to], $spaces[name].components, $spaces[from].converters[name]);
				return;
			}
		}
	}
	function $from(that, args) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(that === void 0 || that === null) {
			throw new TypeError("'that' is not nullable");
		}
		else if(!Type.is(that, Color)) {
			throw new TypeError("'that' is not of type 'Color'");
		}
		if(args === void 0 || args === null) {
			throw new TypeError("'args' is not nullable");
		}
		else if(!Type.isArray(args)) {
			throw new TypeError("'args' is not of type 'Array'");
		}
		that._dummy = false;
		if(args.length === 0) {
			return that;
		}
		else if(Type.isString(args[0]) && Type.isValue($parsers[args[0]])) {
			if($parsers[args.shift()](that, args)) {
				return that;
			}
		}
		else {
			for(let name in $parsers) {
				let parse = $parsers[name];
				if(parse(that, args)) {
					return that;
				}
			}
		}
		that._dummy = true;
		return that;
	}
	function $hex(that) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(that === void 0 || that === null) {
			throw new TypeError("'that' is not nullable");
		}
		let chars = "0123456789abcdef";
		let r1 = that._red >> 4;
		let g1 = that._green >> 4;
		let b1 = that._blue >> 4;
		let r2 = that._red & 15;
		let g2 = that._green & 15;
		let b2 = that._blue & 15;
		if(that._alpha === 1) {
			if(((r1 ^ r2) | (g1 ^ g2) | (b1 ^ b2)) === 0) {
				return "#" + chars.charAt(r1) + chars.charAt(g1) + chars.charAt(b1);
			}
			return "#" + chars.charAt(r1) + chars.charAt(r2) + chars.charAt(g1) + chars.charAt(g2) + chars.charAt(b1) + chars.charAt(b2);
		}
		else {
			let a = Math.round(that._alpha * 255);
			let a1 = a >> 4;
			let a2 = a & 15;
			if(((r1 ^ r2) | (g1 ^ g2) | (b1 ^ b2) | (a1 ^ a2)) === 0) {
				return "#" + chars.charAt(r1) + chars.charAt(g1) + chars.charAt(b1) + chars.charAt(a1);
			}
			return "#" + chars.charAt(r1) + chars.charAt(r2) + chars.charAt(g1) + chars.charAt(g2) + chars.charAt(b1) + chars.charAt(b2) + chars.charAt(a1) + chars.charAt(a2);
		}
	}
	let $parsers = {
		srgb(that, args) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(that === void 0 || that === null) {
				throw new TypeError("'that' is not nullable");
			}
			else if(!Type.is(that, Color)) {
				throw new TypeError("'that' is not of type 'Color'");
			}
			if(args === void 0 || args === null) {
				throw new TypeError("'args' is not nullable");
			}
			else if(!Type.isArray(args)) {
				throw new TypeError("'args' is not of type 'Array'");
			}
			if(args.length === 1) {
				if(Type.isNumber(args[0])) {
					that._space = Space.SRGB;
					that._alpha = $caster.alpha(((args[0] >> 24) & 255) / 255);
					that._red = (args[0] >> 16) & 255;
					that._green = (args[0] >> 8) & 255;
					that._blue = args[0] & 255;
					return true;
				}
				else if(Type.isArray(args[0])) {
					that._space = Space.SRGB;
					that._alpha = (args[0].length === 4) ? $caster.alpha(args[0][3]) : 1;
					that._red = $caster.ff(args[0][0]);
					that._green = $caster.ff(args[0][1]);
					that._blue = $caster.ff(args[0][2]);
					return true;
				}
				else if(Type.isObject(args[0])) {
					if(Type.isValue(args[0].r) && Type.isValue(args[0].g) && Type.isValue(args[0].b)) {
						that._space = Space.SRGB;
						that._alpha = $caster.alpha(args[0].a);
						that._red = $caster.ff(args[0].r);
						that._green = $caster.ff(args[0].g);
						that._blue = $caster.ff(args[0].b);
						return true;
					}
					if(Type.isValue(args[0].red) && Type.isValue(args[0].green) && Type.isValue(args[0].blue)) {
						that._space = Space.SRGB;
						that._alpha = $caster.alpha(args[0].alpha);
						that._red = $caster.ff(args[0].red);
						that._green = $caster.ff(args[0].green);
						that._blue = $caster.ff(args[0].blue);
						return true;
					}
				}
				else if(Type.isString(args[0])) {
					let color = __ks_String._im_lower(args[0]).replace(/[^a-z0-9,.()#%]/g, "");
					if("transparent" === color) {
						that._alpha = that._red = that._green = that._blue = 0;
						return true;
					}
					else if("rand" === color) {
						let c = (Math.random() * 16777215) | 0;
						that._space = Space.SRGB;
						that._alpha = 1;
						that._red = (c >> 16) & 255;
						that._green = (c >> 8) & 255;
						that._blue = c & 255;
						return true;
					}
					if(Type.isValue($names[color])) {
						color = "#" + $names[color];
					}
					let match, __ks_0;
					if(Type.isValue(__ks_0 = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = Integer.parse(match[1], 16);
						that._green = Integer.parse(match[2], 16);
						that._blue = Integer.parse(match[3], 16);
						that._alpha = $caster.alpha(Integer.parse(match[4], 16) / 255);
						return true;
					}
					else if(Type.isValue(__ks_0 = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = Integer.parse(match[1], 16);
						that._green = Integer.parse(match[2], 16);
						that._blue = Integer.parse(match[3], 16);
						that._alpha = 1;
						return true;
					}
					else if(Type.isValue(__ks_0 = /^#?([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = Integer.parse(match[1] + match[1], 16);
						that._green = Integer.parse(match[2] + match[2], 16);
						that._blue = Integer.parse(match[3] + match[3], 16);
						that._alpha = $caster.alpha(Integer.parse(match[4] + match[4], 16) / 255);
						return true;
					}
					else if(Type.isValue(__ks_0 = /^#?([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = Integer.parse(match[1] + match[1], 16);
						that._green = Integer.parse(match[2] + match[2], 16);
						that._blue = Integer.parse(match[3] + match[3], 16);
						that._alpha = 1;
						return true;
					}
					else if(Type.isValue(__ks_0 = /^rgba?\((\d{1,3}),(\d{1,3}),(\d{1,3})(,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = $caster.ff(match[1]);
						that._green = $caster.ff(match[2]);
						that._blue = $caster.ff(match[3]);
						that._alpha = $caster.alpha(match[5], match[6]);
						return true;
					}
					else if(Type.isValue(__ks_0 = /^rgba?\(([0-9.]+\%),([0-9.]+\%),([0-9.]+\%)(,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = Math.round(2.55 * $caster.percentage(match[1]));
						that._green = Math.round(2.55 * $caster.percentage(match[2]));
						that._blue = Math.round(2.55 * $caster.percentage(match[3]));
						that._alpha = $caster.alpha(match[5], match[6]);
						return true;
					}
					else if(Type.isValue(__ks_0 = /^rgba?\(#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2}),([0-9.]+)(\%)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = Integer.parse(match[1], 16);
						that._green = Integer.parse(match[2], 16);
						that._blue = Integer.parse(match[3], 16);
						that._alpha = $caster.alpha(match[4], match[5]);
						return true;
					}
					else if(Type.isValue(__ks_0 = /^rgba\(#?([0-9a-f])([0-9a-f])([0-9a-f]),([0-9.]+)(\%)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = Integer.parse(match[1] + match[1], 16);
						that._green = Integer.parse(match[2] + match[2], 16);
						that._blue = Integer.parse(match[3] + match[3], 16);
						that._alpha = $caster.alpha(match[4], match[5]);
						return true;
					}
					else if(Type.isValue(__ks_0 = /^(\d{1,3}),(\d{1,3}),(\d{1,3})(?:,([0-9.]+))?$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = $caster.ff(match[1]);
						that._green = $caster.ff(match[2]);
						that._blue = $caster.ff(match[3]);
						that._alpha = $caster.alpha(match[4]);
						return true;
					}
				}
			}
			else if(args.length >= 3) {
				that._space = Space.SRGB;
				that._alpha = (args.length >= 4) ? $caster.alpha(args[3]) : 1;
				that._red = $caster.ff(args[0]);
				that._green = $caster.ff(args[1]);
				that._blue = $caster.ff(args[2]);
				return true;
			}
			return false;
		},
		gray(that, args) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(that === void 0 || that === null) {
				throw new TypeError("'that' is not nullable");
			}
			else if(!Type.is(that, Color)) {
				throw new TypeError("'that' is not of type 'Color'");
			}
			if(args === void 0 || args === null) {
				throw new TypeError("'args' is not nullable");
			}
			else if(!Type.isArray(args)) {
				throw new TypeError("'args' is not of type 'Array'");
			}
			if(args.length === 1) {
				if(Type.isNumeric(args[0])) {
					that._space = Space.SRGB;
					that._red = that._green = that._blue = $caster.ff(args[0]);
					that._alpha = (args.length >= 2) ? $caster.alpha(args[1]) : 1;
					return true;
				}
				else if(Type.isString(args[0])) {
					let color = __ks_String._im_lower(args[0]).replace(/[^a-z0-9,.()#%]/g, "");
					let match, __ks_1;
					if(Type.isValue(__ks_1 = /^gray\((\d{1,3})(?:,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_1, true) : false) {
						that._space = Space.SRGB;
						that._red = that._green = that._blue = $caster.ff(match[1]);
						that._alpha = $caster.alpha(match[2], match[3]);
						return true;
					}
					else if(Type.isValue(__ks_1 = /^gray\(([0-9.]+\%)(?:,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_1, true) : false) {
						that._space = Space.SRGB;
						that._red = that._green = that._blue = Math.round(2.55 * $caster.percentage(match[1]));
						that._alpha = $caster.alpha(match[2], match[3]);
						return true;
					}
				}
			}
			return false;
		}
	};
	function $space(name) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		else if(!Type.isString(name)) {
			throw new TypeError("'name' is not of type 'String'");
		}
		$spaces[name] = Type.isValue($spaces[name]) ? $spaces[name] : {
			alias: {},
			converters: {},
			components: {}
		};
	}
	let Space = {
		RGB: "rgb",
		SRGB: "srgb"
	};
	class Color {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._dummy = false;
			this._space = Space.SRGB;
			this._alpha = 0;
			this._red = 0;
			this._green = 0;
			this._blue = 0;
		}
		__ks_init() {
			Color.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0(...args) {
			$from(this, args);
		}
		__ks_cons(args) {
			Color.prototype.__ks_cons_0.apply(this, args);
		}
		__ks_func_alpha_0() {
			return this._alpha;
		}
		__ks_func_alpha_1(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!(Type.isString(value) || Type.isNumber(value))) {
				throw new TypeError("'value' is not of type 'String' or 'Number'");
			}
			this._alpha = $caster.alpha(value);
			return this;
		}
		alpha() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_alpha_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Color.prototype.__ks_func_alpha_1.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_blend_0() {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let color = arguments[++__ks_i];
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.is(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
			}
			let percentage = arguments[++__ks_i];
			if(percentage === void 0 || percentage === null) {
				throw new TypeError("'percentage' is not nullable");
			}
			else if(!Type.isNumber(percentage)) {
				throw new TypeError("'percentage' is not of type 'float'");
			}
			let space;
			if(arguments.length > 2 && (space = arguments[++__ks_i]) !== void 0 && space !== null) {
				if(!Type.is(space, Space)) {
					throw new TypeError("'space' is not of type 'Space'");
				}
			}
			else {
				space = Space.SRGB;
			}
			let alpha;
			if(arguments.length > 3 && (alpha = arguments[++__ks_i]) !== void 0 && alpha !== null) {
				if(!Type.isBoolean(alpha)) {
					throw new TypeError("'alpha' is not of type 'Boolean'");
				}
			}
			else {
				alpha = false;
			}
			if(alpha) {
				let w = (percentage * 2) - 1;
				let a = color._alpha - this._alpha;
				this._alpha = __ks_Number._im_round($blend(this._alpha, color._alpha, percentage), 2);
				if((w * a) === -1) {
					percentage = w;
				}
				else {
					percentage = (w + a) / (1 + (w * a));
				}
			}
			space = $aliases[space] || space;
			this.space(space);
			color = color.like(space);
			let components = $spaces[space].components;
			for(let name in components) {
				let component = components[name];
				if(component.loop) {
					let d = Math.abs(this[component.field] - color[component.field]);
					if(d > component.half) {
						d = component.mod - d;
					}
					this[component.field] = __ks_Number._im_round((this[component.field] + (d * percentage)) % component.mod, component.round);
				}
				else {
					this[component.field] = __ks_Number._im_round(__ks_Number._im_limit($blend(this[component.field], color[component.field], percentage), component.min, component.max), component.round);
				}
			}
			return this;
		}
		blend() {
			if(arguments.length >= 2 && arguments.length <= 4) {
				return Color.prototype.__ks_func_blend_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_clearer_0(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!(Type.isString(value) || Type.isNumber(value))) {
				throw new TypeError("'value' is not of type 'String' or 'Number'");
			}
			if(Type.isString(value) && value.endsWith("%")) {
				return this.alpha(this._alpha * ((100 - __ks_String._im_toFloat(value)) / 100));
			}
			else {
				return this.alpha(this._alpha - (Type.isString(value) ? __ks_String._im_toFloat(value) : __ks_Number._im_toFloat(value)));
			}
		}
		clearer() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_clearer_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_clone_0() {
			return this.copy(new Color());
		}
		clone() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_clone_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_contrast_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.is(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
			}
			let a = this._alpha;
			if(a === 1) {
				if(color._alpha !== 1) {
					color = color.clone().blend(this, 0.5, Space.SRGB, true);
				}
				let l1 = this.luminance() + 0.05;
				let l2 = color.luminance() + 0.05;
				let ratio = l1 / l2;
				if(l2 > l1) {
					ratio = 1 / ratio;
				}
				ratio = __ks_Number._im_round(ratio, 2);
				return {
					ratio,
					error: 0,
					min: ratio,
					max: ratio
				};
			}
			else {
				let black = this.clone().blend($static.black, 0.5, Space.SRGB, true).contrast(color).ratio;
				let white = this.clone().blend($static.white, 0.5, Space.SRGB, true).contrast(color).ratio;
				let max = Math.max(black, white);
				let closest = new Color(__ks_Number._im_limit((color._red - (this._red * a)) / (1 - a), 0, 255), __ks_Number._im_limit((color._green - (this._green * a)) / (1 - a), 0, 255), __ks_Number._im_limit((color._blue - (this._blue * a)) / (1 - a), 0, 255));
				let min = this.clone().blend(closest, 0.5, Space.SRGB, true).contrast(color).ratio;
				return {
					ratio: __ks_Number._im_round((min + max) / 2, 2),
					error: __ks_Number._im_round((max - min) / 2, 2),
					min,
					max
				};
			}
		}
		contrast() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_contrast_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_copy_0(target) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(target === void 0 || target === null) {
				throw new TypeError("'target' is not nullable");
			}
			else if(!Type.is(target, Color)) {
				throw new TypeError("'target' is not of type 'Color'");
			}
			let s1 = this._space;
			let s2 = target._space;
			this.space(Space.SRGB);
			target.space(Space.SRGB);
			target._red = this._red;
			target._green = this._green;
			target._blue = this._blue;
			target._alpha = this._alpha;
			target._dummy = this._dummy;
			this.space(s1);
			target.space(s2);
			return target;
		}
		copy() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_copy_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_distance_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.is(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
			}
			let that = this.like(Space.SRGB);
			color = color.like(Space.SRGB);
			return Math.sqrt((3 * (color._red - that._red) * (color._red - that._red)) + (4 * (color._green - that._green) * (color._green - that._green)) + (2 * (color._blue - that._blue) * (color._blue - that._blue)));
		}
		distance() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_distance_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_equals_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.is(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
			}
			return this.hex() === color.hex();
		}
		equals() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_equals_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_format_0(format) {
			if(format === void 0 || format === null) {
				format = this._space;
			}
			else if(!Type.isString(format)) {
				throw new TypeError("'format' is not of type 'String'");
			}
			if(Type.isValue($formatters[format]) ? (format = $formatters[format], true) : false) {
				return format.formatter(Type.isValue(format.space) ? this.like(format.space) : this);
			}
			else {
				return false;
			}
		}
		format() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Color.prototype.__ks_func_format_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_from_0(...args) {
			return $from(this, args);
		}
		from() {
			return Color.prototype.__ks_func_from_0.apply(this, arguments);
		}
		__ks_func_getField_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			const component = $components[name];
			if(Type.isValue(component.spaces[this._space])) {
				return this[component.field];
			}
			else if(component.families.length > 1) {
				throw new Error("The component '" + name + "' has a conflict between the spaces '" + component.families.join("', '") + "'");
			}
			else {
				return this.like(component.families[0])[component.field];
			}
		}
		getField() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_getField_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_gradient_0(endColor, length) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(endColor === void 0 || endColor === null) {
				throw new TypeError("'endColor' is not nullable");
			}
			else if(!Type.is(endColor, Color)) {
				throw new TypeError("'endColor' is not of type 'Color'");
			}
			if(length === void 0 || length === null) {
				throw new TypeError("'length' is not nullable");
			}
			else if(!Type.isNumber(length)) {
				throw new TypeError("'length' is not of type 'int'");
			}
			let gradient = [this];
			if(length > 0) {
				this.space(Space.SRGB);
				endColor.space(Space.SRGB);
				++length;
				let red = endColor._red - this._red;
				let green = endColor._green - this._green;
				let blue = endColor._blue - this._blue;
				for(let i = 1; i < length; ++i) {
					let offset = i / length;
					let color = this.clone();
					color._red += Math.round(red * offset);
					color._green += Math.round(green * offset);
					color._blue += Math.round(blue * offset);
					gradient.push(color);
				}
			}
			gradient.push(endColor);
			return gradient;
		}
		gradient() {
			if(arguments.length === 2) {
				return Color.prototype.__ks_func_gradient_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_greyscale_0(model) {
			if(model === void 0 || model === null) {
				model = "BT709";
			}
			else if(!Type.isString(model)) {
				throw new TypeError("'model' is not of type 'String'");
			}
			this.space(Space.SRGB);
			if(model === "BT709") {
				this._red = this._green = this._blue = Math.round((0.2126 * this._red) + (0.7152 * this._green) + (0.0722 * this._blue));
			}
			else if(model === "average") {
				this._red = this._green = this._blue = Math.round((this._red + this._green + this._blue) / 3);
			}
			else if(model === "lightness") {
				this._red = this._green = this._blue = Math.round((Math.max(this._red, this._green, this._blue) + Math.min(this._red, this._green, this._blue)) / 3);
			}
			else if(model === "Y") {
				this._red = this._green = this._blue = Math.round((0.299 * this._red) + (0.587 * this._green) + (0.114 * this._blue));
			}
			else if(model === "RMY") {
				this._red = this._green = this._blue = Math.round((0.5 * this._red) + (0.419 * this._green) + (0.081 * this._blue));
			}
			return this;
		}
		greyscale() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Color.prototype.__ks_func_greyscale_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_hex_0() {
			return $hex(this.like(Space.SRGB));
		}
		hex() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_hex_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_isBlack_0() {
			let that = this.like(Space.SRGB);
			return (that._red === 0) && (that._green === 0) && (that._blue === 0);
		}
		isBlack() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_isBlack_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_isTransparent_0() {
			if(this._alpha === 0) {
				let that = this.like(Space.SRGB);
				return (that._red === 0) && (that._green === 0) && (that._blue === 0);
			}
			else {
				return false;
			}
		}
		isTransparent() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_isTransparent_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_isWhite_0() {
			let that = this.like(Space.SRGB);
			return (that._red === 255) && (that._green === 255) && (that._blue === 255);
		}
		isWhite() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_isWhite_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_like_0(space) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(space === void 0 || space === null) {
				throw new TypeError("'space' is not nullable");
			}
			else if(!Type.isString(space)) {
				throw new TypeError("'space' is not of type 'String'");
			}
			space = Type.isValue($aliases[space]) ? $aliases[space] : space;
			if((this._space === space) || Type.isValue($spaces[this._space][space])) {
				return this;
			}
			else {
				return $convert(this, space);
			}
		}
		like() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_like_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_luminance_0() {
			let that = this.like(Space.SRGB);
			let r = that._red / 255;
			r = (r < 0.03928) ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
			let g = that._green / 255;
			g = (g < 0.03928) ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
			let b = that._blue / 255;
			b = (b < 0.03928) ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);
			return (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
		}
		luminance() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_luminance_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_negative_0() {
			this.space(Space.SRGB);
			this._red ^= 255;
			this._green ^= 255;
			this._blue ^= 255;
			return this;
		}
		negative() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_negative_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_opaquer_0(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!(Type.isString(value) || Type.isNumber(value))) {
				throw new TypeError("'value' is not of type 'String' or 'Number'");
			}
			if(Type.isString(value) && value.endsWith("%")) {
				return this.alpha(this._alpha * ((100 + __ks_String._im_toFloat(value)) / 100));
			}
			else {
				return this.alpha(this._alpha + (Type.isString(value) ? __ks_String._im_toFloat(value) : __ks_Number._im_toFloat(value)));
			}
		}
		opaquer() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_opaquer_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_readable_0() {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let color = arguments[++__ks_i];
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.is(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
			}
			let tripleA;
			if(arguments.length > 1 && (tripleA = arguments[++__ks_i]) !== void 0 && tripleA !== null) {
				if(!Type.isBoolean(tripleA)) {
					throw new TypeError("'tripleA' is not of type 'Boolean'");
				}
			}
			else {
				tripleA = false;
			}
			if(tripleA) {
				return this.contrast(color).ratio >= 7;
			}
			else {
				return this.contrast(color).ratio >= 4.5;
			}
		}
		readable() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Color.prototype.__ks_func_readable_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_scheme_0(functions) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(functions === void 0 || functions === null) {
				throw new TypeError("'functions' is not nullable");
			}
			else if(!Type.isArray(functions, Function)) {
				throw new TypeError("'functions' is not of type 'Array'");
			}
			return Helper.mapArray(functions, (fn) => {
				return fn(this.clone());
			});
		}
		scheme() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_scheme_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_setField_0(name, value) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!(Type.isNumber(value) || Type.isString(value))) {
				throw new TypeError("'value' is not of type 'Number' or 'String'");
			}
			let component;
			if(Type.isValue($components[name].spaces[this._space])) {
				component = $spaces[this._space].components[name];
			}
			else if(component.families.length > 1) {
				throw new Error("The component '" + name + "' has a conflict between the spaces '" + component.families.join("', '") + "'");
			}
			else {
				this.space(component.families[0]);
				component = $spaces[component.families[0]].components[name];
			}
			if(Type.isValue(component.parser)) {
				this[component.field] = component.parser(value);
			}
			else if(component.loop) {
				this[component.field] = __ks_Number._im_round(__ks_Number._im_mod(Type.isNumber(value) ? __ks_Number._im_toFloat(value) : __ks_String._im_toFloat(value), component.mod), component.round);
			}
			else {
				this[component.field] = __ks_Number._im_round(__ks_Number._im_limit(Type.isNumber(value) ? __ks_Number._im_toFloat(value) : __ks_String._im_toFloat(value), component.min, component.max), component.round);
			}
			return this;
		}
		setField() {
			if(arguments.length === 2) {
				return Color.prototype.__ks_func_setField_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_shade_0(percentage) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(percentage === void 0 || percentage === null) {
				throw new TypeError("'percentage' is not nullable");
			}
			else if(!Type.isNumber(percentage)) {
				throw new TypeError("'percentage' is not of type 'float'");
			}
			return this.blend($static.black, percentage);
		}
		shade() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_shade_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_space_0() {
			return this._space;
		}
		__ks_func_space_1(space) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(space === void 0 || space === null) {
				throw new TypeError("'space' is not nullable");
			}
			else if(!Type.isString(space)) {
				throw new TypeError("'space' is not of type 'String'");
			}
			space = Type.isValue($aliases[space]) ? $aliases[space] : space;
			if(!Type.isValue($spaces[space]) && Type.isValue($components[space])) {
				if(Type.isValue($spaces[this._space].components[space])) {
					return this;
				}
				else if($components[space].families.length === 1) {
					space = $components[space].families[0];
				}
				else {
					throw new Error("The component '" + space + "' has a conflict between the spaces '" + $components[space].families.join("', '") + "'");
				}
			}
			if((this._space !== space) && !Type.isValue($spaces[this._space][space])) {
				$convert(this, space, this);
			}
			return this;
		}
		space() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_space_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Color.prototype.__ks_func_space_1.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_tint_0(percentage) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(percentage === void 0 || percentage === null) {
				throw new TypeError("'percentage' is not nullable");
			}
			else if(!Type.isNumber(percentage)) {
				throw new TypeError("'percentage' is not of type 'float'");
			}
			return this.blend($static.white, percentage);
		}
		tint() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_tint_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_tone_0(percentage) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(percentage === void 0 || percentage === null) {
				throw new TypeError("'percentage' is not nullable");
			}
			else if(!Type.isNumber(percentage)) {
				throw new TypeError("'percentage' is not of type 'float'");
			}
			return this.blend($static.gray, percentage);
		}
		tone() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_tone_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		static __ks_sttc_from_0(...args) {
			let color = $from(new Color(), args);
			return color._dummy ? false : color;
		}
		static from() {
			return Color.__ks_sttc_from_0.apply(this, arguments);
		}
		static __ks_sttc_greyscale_0(...args) {
			let model = __ks_Array._im_last(args);
			if((model === "BT709") || (model === "average") || (model === "lightness") || (model === "Y") || (model === "RMY")) {
				args.pop();
			}
			else {
				model = null;
			}
			let color = $from(new Color(), args);
			return color._dummy ? false : color.greyscale(model);
		}
		static greyscale() {
			return Color.__ks_sttc_greyscale_0.apply(this, arguments);
		}
		static __ks_sttc_hex_0(...args) {
			let color = $from(new Color(), args);
			return color._dummy ? false : color.hex();
		}
		static hex() {
			return Color.__ks_sttc_hex_0.apply(this, arguments);
		}
		static __ks_sttc_negative_0(...args) {
			let color = $from(new Color(), args);
			return color._dummy ? false : color.negative();
		}
		static negative() {
			return Color.__ks_sttc_negative_0.apply(this, arguments);
		}
		static __ks_sttc_registerFormatter_0(format, formatter) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(format === void 0 || format === null) {
				throw new TypeError("'format' is not nullable");
			}
			else if(!Type.isString(format)) {
				throw new TypeError("'format' is not of type 'String'");
			}
			if(formatter === void 0 || formatter === null) {
				throw new TypeError("'formatter' is not nullable");
			}
			else if(!Type.isFunction(formatter)) {
				throw new TypeError("'formatter' is not of type 'Function'");
			}
			$formatters[format] = {
				formatter
			};
		}
		static registerFormatter() {
			if(arguments.length === 2) {
				return Color.__ks_sttc_registerFormatter_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		static __ks_sttc_registerParser_0(format, parser) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(format === void 0 || format === null) {
				throw new TypeError("'format' is not nullable");
			}
			else if(!Type.isString(format)) {
				throw new TypeError("'format' is not of type 'String'");
			}
			if(parser === void 0 || parser === null) {
				throw new TypeError("'parser' is not nullable");
			}
			else if(!Type.isFunction(parser)) {
				throw new TypeError("'parser' is not of type 'Function'");
			}
			$parsers[format] = parser;
		}
		static registerParser() {
			if(arguments.length === 2) {
				return Color.__ks_sttc_registerParser_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		static __ks_sttc_registerSpace_0(space) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(space === void 0 || space === null) {
				throw new TypeError("'space' is not nullable");
			}
			else if(!Type.isObject(space)) {
				throw new TypeError("'space' is not of type 'Object'");
			}
			let spaces = Object.keys($spaces);
			$space(space.name);
			if(Type.isValue(space.parser)) {
				$parsers[space.name] = space.parser;
			}
			if(Type.isValue(space.formatter)) {
				$formatters[space.name] = {
					space: space.name,
					formatter: space.formatter
				};
			}
			else if(Type.isValue(space.formatters)) {
				for(let name in space.formatters) {
					let formatter = space.formatters[name];
					$formatters[name] = {
						space: space.name,
						formatter
					};
				}
			}
			if(Type.isValue(space.alias)) {
				for(let __ks_2 = 0, __ks_3 = space.alias.length, alias; __ks_2 < __ks_3; ++__ks_2) {
					alias = space.alias[__ks_2];
					$spaces[space.name].alias[alias] = true;
					$aliases[alias] = space.name;
				}
				if(Type.isValue($parsers[space.name])) {
					for(let __ks_4 = 0, __ks_5 = space.alias.length, alias; __ks_4 < __ks_5; ++__ks_4) {
						alias = space.alias[__ks_4];
						$parsers[alias] = $parsers[space.name];
					}
				}
				if(Type.isValue($formatters[space.name])) {
					for(let __ks_6 = 0, __ks_7 = space.alias.length, alias; __ks_6 < __ks_7; ++__ks_6) {
						alias = space.alias[__ks_6];
						$formatters[alias] = $formatters[space.name];
					}
				}
			}
			if(Type.isValue(space.converters)) {
				if(Type.isValue(space.converters.from)) {
					for(let name in space.converters.from) {
						let converter = space.converters.from[name];
						if(Type.isValue(!$spaces[name])) {
							$space(name);
						}
						$spaces[name].converters[space.name] = converter;
					}
				}
				if(Type.isValue(space.converters.to)) {
					for(let name in space.converters.to) {
						let converter = space.converters.to[name];
						$spaces[space.name].converters[name] = converter;
					}
				}
			}
			for(let __ks_8 = 0, __ks_9 = spaces.length, name; __ks_8 < __ks_9; ++__ks_8) {
				name = spaces[__ks_8];
				if(Type.isValue(!$spaces[name].converters[space.name])) {
					$find(name, space.name);
				}
				if(Type.isValue(!$spaces[space.name].converters[name])) {
					$find(space.name, name);
				}
			}
			if(Type.isValue(space.components)) {
				for(let name in space.components) {
					let component = space.components[name];
					if(Type.isValue(component.family)) {
						$spaces[space.name].components[name] = $spaces[component.family].components[name];
						$components[name].spaces[space.name] = true;
					}
					else if(Type.isValue(component.mutator)) {
						$component(component, name, space.name);
					}
					else {
						if(!Type.isValue(component.min)) {
							component.min = 0;
						}
						if(!Type.isValue(component.round)) {
							component.round = 0;
						}
						if(!Type.isValue(component.loop) || (component.min !== 0)) {
							component.loop = false;
						}
						else if(component.loop) {
							component.mod = component.max + 1;
							component.half = component.mod / 2;
						}
						$component(component, name, space.name);
					}
				}
			}
		}
		static registerSpace() {
			if(arguments.length === 1) {
				return Color.__ks_sttc_registerSpace_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	Color.registerSpace({
		name: Space.SRGB,
		"alias": [Space.RGB],
		"formatters": {
			hex(that) {
				if(arguments.length < 1) {
					throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(that === void 0 || that === null) {
					throw new TypeError("'that' is not nullable");
				}
				else if(!Type.is(that, Color)) {
					throw new TypeError("'that' is not of type 'Color'");
				}
				return $hex(that);
			},
			srgb(that) {
				if(arguments.length < 1) {
					throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(that === void 0 || that === null) {
					throw new TypeError("'that' is not nullable");
				}
				else if(!Type.is(that, Color)) {
					throw new TypeError("'that' is not of type 'Color'");
				}
				if(that._alpha === 1) {
					return "rgb(" + that._red + ", " + that._green + ", " + that._blue + ")";
				}
				else {
					return "rgba(" + that._red + ", " + that._green + ", " + that._blue + ", " + that._alpha + ")";
				}
			}
		},
		"components": {
			"red": {
				"max": 255
			},
			"green": {
				"max": 255
			},
			"blue": {
				"max": 255
			}
		}
	});
	Color.prototype.__ks_func_red_0 = function() {
		return this.getField("red");
	};
	Color.prototype.__ks_func_red_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("red", value);
	};
	Color.prototype.__ks_func_green_0 = function() {
		return this.getField("green");
	};
	Color.prototype.__ks_func_green_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("green", value);
	};
	Color.prototype.__ks_func_blue_0 = function() {
		return this.getField("blue");
	};
	Color.prototype.__ks_func_blue_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		return this.setField("blue", value);
	};
	Color.prototype.red = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_red_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_red_1.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	Color.prototype.green = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_green_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_green_1.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	Color.prototype.blue = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_blue_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_blue_1.apply(this, arguments);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	let $static = {
		black: Color.from("#000"),
		gray: Color.from("#808080"),
		white: Color.from("#fff")
	};
	return {
		Space: Space,
		Color: Color
	};
};
require("kaoscript/register");
var {Dictionary, Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {Array, __ks_Array} = require("./_/_array.ks")();
	var Float = require("./_/_float.ks")().Float;
	var Integer = require("./_/_integer.ks")().Integer;
	var {Math, __ks_Math} = require("./_/_math.ks")();
	var {Number, __ks_Number} = require("./_/_number.ks")();
	var {String, __ks_String} = require("./_/_string.ks")();
	let $spaces = new Dictionary();
	let $aliases = new Dictionary();
	let $components = new Dictionary();
	let $formatters = new Dictionary();
	const $names = (() => {
		const d = new Dictionary();
		d["aliceblue"] = "f0f8ff";
		d["antiquewhite"] = "faebd7";
		d["aqua"] = "0ff";
		d["aquamarine"] = "7fffd4";
		d["azure"] = "f0ffff";
		d["beige"] = "f5f5dc";
		d["bisque"] = "ffe4c4";
		d["black"] = "000";
		d["blanchedalmond"] = "ffebcd";
		d["blue"] = "00f";
		d["blueviolet"] = "8a2be2";
		d["brown"] = "a52a2a";
		d["burlywood"] = "deb887";
		d["burntsienna"] = "ea7e5d";
		d["cadetblue"] = "5f9ea0";
		d["chartreuse"] = "7fff00";
		d["chocolate"] = "d2691e";
		d["coral"] = "ff7f50";
		d["cornflowerblue"] = "6495ed";
		d["cornsilk"] = "fff8dc";
		d["crimson"] = "dc143c";
		d["cyan"] = "0ff";
		d["darkblue"] = "00008b";
		d["darkcyan"] = "008b8b";
		d["darkgoldenrod"] = "b8860b";
		d["darkgray"] = "a9a9a9";
		d["darkgreen"] = "006400";
		d["darkgrey"] = "a9a9a9";
		d["darkkhaki"] = "bdb76b";
		d["darkmagenta"] = "8b008b";
		d["darkolivegreen"] = "556b2f";
		d["darkorange"] = "ff8c00";
		d["darkorchid"] = "9932cc";
		d["darkred"] = "8b0000";
		d["darksalmon"] = "e9967a";
		d["darkseagreen"] = "8fbc8f";
		d["darkslateblue"] = "483d8b";
		d["darkslategray"] = "2f4f4f";
		d["darkslategrey"] = "2f4f4f";
		d["darkturquoise"] = "00ced1";
		d["darkviolet"] = "9400d3";
		d["deeppink"] = "ff1493";
		d["deepskyblue"] = "00bfff";
		d["dimgray"] = "696969";
		d["dimgrey"] = "696969";
		d["dodgerblue"] = "1e90ff";
		d["firebrick"] = "b22222";
		d["floralwhite"] = "fffaf0";
		d["forestgreen"] = "228b22";
		d["fuchsia"] = "f0f";
		d["gainsboro"] = "dcdcdc";
		d["ghostwhite"] = "f8f8ff";
		d["gold"] = "ffd700";
		d["goldenrod"] = "daa520";
		d["gray"] = "808080";
		d["green"] = "008000";
		d["greenyellow"] = "adff2f";
		d["grey"] = "808080";
		d["honeydew"] = "f0fff0";
		d["hotpink"] = "ff69b4";
		d["indianred"] = "cd5c5c";
		d["indigo"] = "4b0082";
		d["ivory"] = "fffff0";
		d["khaki"] = "f0e68c";
		d["lavender"] = "e6e6fa";
		d["lavenderblush"] = "fff0f5";
		d["lawngreen"] = "7cfc00";
		d["lemonchiffon"] = "fffacd";
		d["lightblue"] = "add8e6";
		d["lightcoral"] = "f08080";
		d["lightcyan"] = "e0ffff";
		d["lightgoldenrodyellow"] = "fafad2";
		d["lightgray"] = "d3d3d3";
		d["lightgreen"] = "90ee90";
		d["lightgrey"] = "d3d3d3";
		d["lightpink"] = "ffb6c1";
		d["lightsalmon"] = "ffa07a";
		d["lightseagreen"] = "20b2aa";
		d["lightskyblue"] = "87cefa";
		d["lightslategray"] = "789";
		d["lightslategrey"] = "789";
		d["lightsteelblue"] = "b0c4de";
		d["lightyellow"] = "ffffe0";
		d["lime"] = "0f0";
		d["limegreen"] = "32cd32";
		d["linen"] = "faf0e6";
		d["magenta"] = "f0f";
		d["maroon"] = "800000";
		d["mediumaquamarine"] = "66cdaa";
		d["mediumblue"] = "0000cd";
		d["mediumorchid"] = "ba55d3";
		d["mediumpurple"] = "9370db";
		d["mediumseagreen"] = "3cb371";
		d["mediumslateblue"] = "7b68ee";
		d["mediumspringgreen"] = "00fa9a";
		d["mediumturquoise"] = "48d1cc";
		d["mediumvioletred"] = "c71585";
		d["midnightblue"] = "191970";
		d["mintcream"] = "f5fffa";
		d["mistyrose"] = "ffe4e1";
		d["moccasin"] = "ffe4b5";
		d["navajowhite"] = "ffdead";
		d["navy"] = "000080";
		d["oldlace"] = "fdf5e6";
		d["olive"] = "808000";
		d["olivedrab"] = "6b8e23";
		d["orange"] = "ffa500";
		d["orangered"] = "ff4500";
		d["orchid"] = "da70d6";
		d["palegoldenrod"] = "eee8aa";
		d["palegreen"] = "98fb98";
		d["paleturquoise"] = "afeeee";
		d["palevioletred"] = "db7093";
		d["papayawhip"] = "ffefd5";
		d["peachpuff"] = "ffdab9";
		d["peru"] = "cd853f";
		d["pink"] = "ffc0cb";
		d["plum"] = "dda0dd";
		d["powderblue"] = "b0e0e6";
		d["purple"] = "800080";
		d["red"] = "f00";
		d["rosybrown"] = "bc8f8f";
		d["royalblue"] = "4169e1";
		d["saddlebrown"] = "8b4513";
		d["salmon"] = "fa8072";
		d["sandybrown"] = "f4a460";
		d["seagreen"] = "2e8b57";
		d["seashell"] = "fff5ee";
		d["sienna"] = "a0522d";
		d["silver"] = "c0c0c0";
		d["skyblue"] = "87ceeb";
		d["slateblue"] = "6a5acd";
		d["slategray"] = "708090";
		d["slategrey"] = "708090";
		d["snow"] = "fffafa";
		d["springgreen"] = "00ff7f";
		d["steelblue"] = "4682b4";
		d["tan"] = "d2b48c";
		d["teal"] = "008080";
		d["thistle"] = "d8bfd8";
		d["tomato"] = "ff6347";
		d["turquoise"] = "40e0d0";
		d["violet"] = "ee82ee";
		d["wheat"] = "f5deb3";
		d["white"] = "fff";
		d["whitesmoke"] = "f5f5f5";
		d["yellow"] = "ff0";
		d["yellowgreen"] = "9acd32";
		return d;
	})();
	function $blend(x, y, percentage) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
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
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
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
		let lastArgs = Helper.mapDictionary(components, function(name, component) {
			return that[component.field];
		});
		lastArgs.push(that);
		return last.call(null, ...lastArgs);
	}
	let $caster = Helper.namespace(function() {
		function alpha() {
			let __ks_i = -1;
			let __ks__;
			let n = arguments.length > 0 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
			let percentage;
			if(arguments.length > ++__ks_i && (percentage = arguments[__ks_i]) !== void 0 && percentage !== null) {
				if(!Type.isBoolean(percentage)) {
					throw new TypeError("'percentage' is not of type 'Boolean'");
				}
			}
			else {
				percentage = false;
			}
			let i = Float.parse(n);
			return Number.isNaN(i) ? 1 : __ks_Number._im_round(__ks_Number._im_limit(percentage ? i / 100 : i, 0, 1), 3);
		}
		function ff(n) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(n === void 0 || n === null) {
				throw new TypeError("'n' is not nullable");
			}
			return __ks_Number._im_round(__ks_Number._im_limit(Float.parse(n), 0, 255));
		}
		function percentage(n) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(n === void 0 || n === null) {
				throw new TypeError("'n' is not nullable");
			}
			return __ks_Number._im_round(__ks_Number._im_limit(Float.parse(n), 0, 100), 1);
		}
		return {
			alpha: alpha,
			ff: ff,
			percentage: percentage
		};
	});
	function $component(component, name, space) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
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
			$components[name] = (() => {
				const d = new Dictionary();
				d.field = component.field;
				d.spaces = new Dictionary();
				d.families = [];
				return d;
			})();
		}
		$components[name].families.push(space);
		$components[name].spaces[space] = true;
	}
	function $convert(that, space, result) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(that === void 0 || that === null) {
			throw new TypeError("'that' is not nullable");
		}
		else if(!Type.isClassInstance(that, Color)) {
			throw new TypeError("'that' is not of type 'Color'");
		}
		if(space === void 0 || space === null) {
			throw new TypeError("'space' is not nullable");
		}
		else if(!Type.isString(space)) {
			throw new TypeError("'space' is not of type 'String'");
		}
		if(result === void 0 || result === null) {
			result = (() => {
				const d = new Dictionary();
				d._alpha = 0;
				return d;
			})();
		}
		else if(!Type.isDictionary(result)) {
			throw new TypeError("'result' is not of type 'Dictionary'");
		}
		let s;
		if(Type.isValue((s = $spaces[that._space]).converters[space])) {
			let args = Helper.mapDictionary(s.components, function(name, component) {
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
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
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
		for(const name in $spaces[from].converters) {
			if(Type.isValue($spaces[name].converters[to])) {
				$spaces[from].converters[to] = Helper.vcurry($binder, null, $spaces[name].converters[to], $spaces[name].components, $spaces[from].converters[name]);
				return;
			}
		}
	}
	function $from(that, args) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(that === void 0 || that === null) {
			throw new TypeError("'that' is not nullable");
		}
		else if(!Type.isClassInstance(that, Color)) {
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
			if($parsers[args.shift()](that, args) === true) {
				return that;
			}
		}
		else {
			for(let name in $parsers) {
				let parse = $parsers[name];
				if(parse(that, args) === true) {
					return that;
				}
			}
		}
		that._dummy = true;
		return that;
	}
	function $hex(that) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(that === void 0 || that === null) {
			throw new TypeError("'that' is not nullable");
		}
		else if(!Type.isClassInstance(that, Color)) {
			throw new TypeError("'that' is not of type 'Color'");
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
	let $parsers = (() => {
		const d = new Dictionary();
		d.srgb = function(that, args) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(that === void 0 || that === null) {
				throw new TypeError("'that' is not nullable");
			}
			else if(!Type.isClassInstance(that, Color)) {
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
				else if(Type.isDictionary(args[0])) {
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
						color = Helper.concatString("#", $names[color]);
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
						that._red = Integer.parse(Operator.addOrConcat(match[1], match[1]), 16);
						that._green = Integer.parse(Operator.addOrConcat(match[2], match[2]), 16);
						that._blue = Integer.parse(Operator.addOrConcat(match[3], match[3]), 16);
						that._alpha = $caster.alpha(Integer.parse(Operator.addOrConcat(match[4], match[4]), 16) / 255);
						return true;
					}
					else if(Type.isValue(__ks_0 = /^#?([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = Integer.parse(Operator.addOrConcat(match[1], match[1]), 16);
						that._green = Integer.parse(Operator.addOrConcat(match[2], match[2]), 16);
						that._blue = Integer.parse(Operator.addOrConcat(match[3], match[3]), 16);
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
						that._red = Integer.parse(Operator.addOrConcat(match[1], match[1]), 16);
						that._green = Integer.parse(Operator.addOrConcat(match[2], match[2]), 16);
						that._blue = Integer.parse(Operator.addOrConcat(match[3], match[3]), 16);
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
		};
		d.gray = function(that, args) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(that === void 0 || that === null) {
				throw new TypeError("'that' is not nullable");
			}
			else if(!Type.isClassInstance(that, Color)) {
				throw new TypeError("'that' is not of type 'Color'");
			}
			if(args === void 0 || args === null) {
				throw new TypeError("'args' is not nullable");
			}
			else if(!Type.isArray(args)) {
				throw new TypeError("'args' is not of type 'Array'");
			}
			if(args.length >= 1) {
				if(Number.isFinite(Float.parse(args[0])) === true) {
					that._space = Space.SRGB;
					that._red = that._green = that._blue = $caster.ff(args[0]);
					that._alpha = (args.length >= 2) ? $caster.alpha(args[1]) : 1;
					return true;
				}
				else if(Type.isString(args[0])) {
					let color = __ks_String._im_lower(args[0]).replace(/[^a-z0-9,.()#%]/g, "");
					let match, __ks_0;
					if(Type.isValue(__ks_0 = /^gray\((\d{1,3})(?:,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = that._green = that._blue = $caster.ff(match[1]);
						that._alpha = $caster.alpha(match[2], match[3]);
						return true;
					}
					else if(Type.isValue(__ks_0 = /^gray\(([0-9.]+\%)(?:,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
						that._space = Space.SRGB;
						that._red = that._green = that._blue = Math.round(2.55 * $caster.percentage(match[1]));
						that._alpha = $caster.alpha(match[2], match[3]);
						return true;
					}
				}
			}
			return false;
		};
		return d;
	})();
	function $space(name) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(name === void 0 || name === null) {
			throw new TypeError("'name' is not nullable");
		}
		else if(!Type.isString(name)) {
			throw new TypeError("'name' is not of type 'String'");
		}
		$spaces[name] = Type.isValue($spaces[name]) ? $spaces[name] : (() => {
			const d = new Dictionary();
			d.alias = new Dictionary();
			d.converters = new Dictionary();
			d.components = new Dictionary();
			return d;
		})();
	}
	let Space = Helper.enum(String, {
		RGB: "rgb",
		SRGB: "srgb"
	});
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
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_blend_0(color, percentage) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isClassInstance(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
			}
			if(percentage === void 0 || percentage === null) {
				throw new TypeError("'percentage' is not nullable");
			}
			else if(!Type.isNumber(percentage)) {
				throw new TypeError("'percentage' is not of type 'float'");
			}
			let __ks_i = 1;
			let space;
			if(arguments.length > ++__ks_i && (space = arguments[__ks_i]) !== void 0 && space !== null) {
				if(!Type.isEnumInstance(space, Space)) {
					if(arguments.length - __ks_i < 2) {
						space = Space.SRGB;
						--__ks_i;
					}
					else {
						throw new TypeError("'space' is not of type 'Space'");
					}
				}
			}
			else {
				space = Space.SRGB;
			}
			let alpha;
			if(arguments.length > ++__ks_i && (alpha = arguments[__ks_i]) !== void 0 && alpha !== null) {
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
			space = Type.isValue($aliases[space]) ? $aliases[space] : space;
			this.space(space);
			color = color.like(space);
			let components = $spaces[space].components;
			for(let name in components) {
				let component = components[name];
				if(component.loop === true) {
					let d = Math.abs(Operator.subtraction(this[component.field], color[component.field]));
					if(Operator.gt(d, component.half)) {
						d = component.mod - d;
					}
					this[component.field] = __ks_Number._im_round(Operator.modulo(this[component.field] + (d * percentage), component.mod), component.round);
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_clearer_0(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!(Type.isString(value) || Type.isNumber(value))) {
				throw new TypeError("'value' is not of type 'String' or 'Number'");
			}
			if(Type.isString(value) && (value.endsWith("%") === true)) {
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_clone_0() {
			return this.copy(new Color());
		}
		clone() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_clone_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_contrast_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isClassInstance(color, Color)) {
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
				return (() => {
					const d = new Dictionary();
					d.ratio = ratio;
					d.error = 0;
					d.min = ratio;
					d.max = ratio;
					return d;
				})();
			}
			else {
				let black = this.clone().blend($static.black, 0.5, Space.SRGB, true).contrast(color).ratio;
				let white = this.clone().blend($static.white, 0.5, Space.SRGB, true).contrast(color).ratio;
				const max = Math.max(black, white);
				let closest = new Color(__ks_Number._im_limit((color._red - (this._red * a)) / (1 - a), 0, 255), __ks_Number._im_limit((color._green - (this._green * a)) / (1 - a), 0, 255), __ks_Number._im_limit((color._blue - (this._blue * a)) / (1 - a), 0, 255));
				const min = this.clone().blend(closest, 0.5, Space.SRGB, true).contrast(color).ratio;
				return (() => {
					const d = new Dictionary();
					d.ratio = __ks_Number._im_round((min + max) / 2, 2);
					d.error = __ks_Number._im_round((max - min) / 2, 2);
					d.min = min;
					d.max = max;
					return d;
				})();
			}
		}
		contrast() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_contrast_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_copy_0(target) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(target === void 0 || target === null) {
				throw new TypeError("'target' is not nullable");
			}
			else if(!Type.isClassInstance(target, Color)) {
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_distance_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isClassInstance(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
			}
			const that = this.like(Space.SRGB);
			color = color.like(Space.SRGB);
			return Math.sqrt((3 * (color._red - that._red) * (color._red - that._red)) + (4 * (color._green - that._green) * (color._green - that._green)) + (2 * (color._blue - that._blue) * (color._blue - that._blue)));
		}
		distance() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_distance_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_equals_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isClassInstance(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
			}
			return this.hex() === color.hex();
		}
		equals() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_equals_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_format_0(format) {
			if(format === void 0 || format === null) {
				format = this._space;
			}
			else if(!Type.isString(format)) {
				throw new TypeError("'format' is not of type 'String'");
			}
			let __ks_format_1 = $formatters[format];
			if(Type.isValue(__ks_format_1)) {
				return __ks_format_1.formatter(Type.isValue(__ks_format_1.space) ? this.like(__ks_format_1.space) : this);
			}
			else {
				return false;
			}
		}
		format() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Color.prototype.__ks_func_format_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_from_0(...args) {
			return $from(this, args);
		}
		from() {
			return Color.prototype.__ks_func_from_0.apply(this, arguments);
		}
		__ks_func_getField_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			const component = $components[name];
			if(Type.isValue(component.spaces[this._space])) {
				return this[component.field];
			}
			else if(Operator.gt(component.families.length, 1)) {
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_gradient_0(endColor, length) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(endColor === void 0 || endColor === null) {
				throw new TypeError("'endColor' is not nullable");
			}
			else if(!Type.isClassInstance(endColor, Color)) {
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
					const offset = i / length;
					const color = this.clone();
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
			throw new SyntaxError("Wrong number of arguments");
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_hex_0() {
			return $hex(this.like(Space.SRGB));
		}
		hex() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_hex_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_isBlack_0() {
			let that = this.like(Space.SRGB);
			return (that._red === 0) && (that._green === 0) && (that._blue === 0);
		}
		isBlack() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_isBlack_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_isWhite_0() {
			let that = this.like(Space.SRGB);
			return (that._red === 255) && (that._green === 255) && (that._blue === 255);
		}
		isWhite() {
			if(arguments.length === 0) {
				return Color.prototype.__ks_func_isWhite_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_like_0(space) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(space === void 0 || space === null) {
				throw new TypeError("'space' is not nullable");
			}
			else if(!Type.isString(space)) {
				throw new TypeError("'space' is not of type 'String'");
			}
			space = Type.isValue($aliases[space]) ? $aliases[space] : space;
			if((this._space.value === space) || Type.isValue($spaces[this._space][space])) {
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_luminance_0() {
			const that = this.like(Space.SRGB);
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
			throw new SyntaxError("Wrong number of arguments");
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_opaquer_0(value) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(value === void 0 || value === null) {
				throw new TypeError("'value' is not nullable");
			}
			else if(!(Type.isString(value) || Type.isNumber(value))) {
				throw new TypeError("'value' is not of type 'String' or 'Number'");
			}
			if(Type.isString(value) && (value.endsWith("%") === true)) {
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_readable_0(color, tripleA) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isClassInstance(color, Color)) {
				throw new TypeError("'color' is not of type 'Color'");
			}
			if(tripleA === void 0 || tripleA === null) {
				tripleA = false;
			}
			else if(!Type.isBoolean(tripleA)) {
				throw new TypeError("'tripleA' is not of type 'Boolean'");
			}
			if(tripleA) {
				return Operator.gte(this.contrast(color).ratio, 7);
			}
			else {
				return Operator.gte(this.contrast(color).ratio, 4.5);
			}
		}
		readable() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Color.prototype.__ks_func_readable_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_scheme_0(functions) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(functions === void 0 || functions === null) {
				throw new TypeError("'functions' is not nullable");
			}
			else if(!Type.isArray(functions, Function)) {
				throw new TypeError("'functions' is not of type 'Array<(color: Color): Color>'");
			}
			return Helper.mapArray(functions, (fn) => {
				return fn(this.clone());
			});
		}
		scheme() {
			if(arguments.length === 1) {
				return Color.prototype.__ks_func_scheme_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_setField_0(name, value) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
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
			let component = $components[name];
			if(Type.isValue(component.spaces[this._space])) {
				component = $spaces[this._space].components[name];
			}
			else if(Operator.gt(component.families.length, 1)) {
				throw new Error("The component '" + name + "' has a conflict between the spaces '" + component.families.join("', '") + "'");
			}
			else {
				this.space(component.families[0]);
				component = $spaces[component.families[0]].components[name];
			}
			if(Type.isValue(component.parser)) {
				this[component.field] = component.parser(value);
			}
			else if(component.loop === true) {
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_shade_0(percentage) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_space_0() {
			return this._space;
		}
		__ks_func_space_1(space) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
			if((this._space.value !== space) && !Type.isValue($spaces[this._space][space])) {
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_tint_0(percentage) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_tone_0(percentage) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
			throw new SyntaxError("Wrong number of arguments");
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
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
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
			$formatters[format] = (() => {
				const d = new Dictionary();
				d.formatter = formatter;
				return d;
			})();
		}
		static registerFormatter() {
			if(arguments.length === 2) {
				return Color.__ks_sttc_registerFormatter_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		static __ks_sttc_registerParser_0(format, parser) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
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
			throw new SyntaxError("Wrong number of arguments");
		}
		static __ks_sttc_registerSpace_0(space) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(space === void 0 || space === null) {
				throw new TypeError("'space' is not nullable");
			}
			else if(!Type.isDictionary(space)) {
				throw new TypeError("'space' is not of type 'Dictionary'");
			}
			let spaces = Dictionary.keys($spaces);
			$space(space.name);
			if(Type.isValue(space.parser)) {
				$parsers[space.name] = space.parser;
			}
			if(Type.isValue(space.formatter)) {
				$formatters[space.name] = (() => {
					const d = new Dictionary();
					d.space = space.name;
					d.formatter = space.formatter;
					return d;
				})();
			}
			else if(Type.isValue(space.formatters)) {
				for(let name in space.formatters) {
					let formatter = space.formatters[name];
					$formatters[name] = (() => {
						const d = new Dictionary();
						d.space = space.name;
						d.formatter = formatter;
						return d;
					})();
				}
			}
			if(Type.isValue(space.alias)) {
				for(let __ks_0 = 0, __ks_1 = space.alias.length, alias; __ks_0 < __ks_1; ++__ks_0) {
					alias = space.alias[__ks_0];
					$spaces[space.name].alias[alias] = true;
					$aliases[alias] = space.name;
				}
				if(Type.isValue($parsers[space.name])) {
					for(let __ks_0 = 0, __ks_1 = space.alias.length, alias; __ks_0 < __ks_1; ++__ks_0) {
						alias = space.alias[__ks_0];
						$parsers[alias] = $parsers[space.name];
					}
				}
				if(Type.isValue($formatters[space.name])) {
					for(let __ks_0 = 0, __ks_1 = space.alias.length, alias; __ks_0 < __ks_1; ++__ks_0) {
						alias = space.alias[__ks_0];
						$formatters[alias] = $formatters[space.name];
					}
				}
			}
			if(Type.isValue(space.converters)) {
				if(Type.isValue(space.converters.from)) {
					for(let name in space.converters.from) {
						let converter = space.converters.from[name];
						if(!Type.isValue($spaces[name])) {
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
			for(let __ks_0 = 0, __ks_1 = spaces.length, name; __ks_0 < __ks_1; ++__ks_0) {
				name = spaces[__ks_0];
				if(!Type.isValue($spaces[name].converters[space.name])) {
					$find(name, space.name);
				}
				if(!Type.isValue($spaces[space.name].converters[name])) {
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
						else if(component.loop === true) {
							component.mod = Operator.addOrConcat(component.max, 1);
							component.half = Operator.division(component.mod, 2);
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
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	Color.registerSpace((() => {
		const d = new Dictionary();
		d.name = Space.SRGB;
		d["alias"] = [Space.RGB];
		d["formatters"] = (() => {
			const d = new Dictionary();
			d.hex = function(that) {
				if(arguments.length < 1) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(that === void 0 || that === null) {
					throw new TypeError("'that' is not nullable");
				}
				else if(!Type.isClassInstance(that, Color)) {
					throw new TypeError("'that' is not of type 'Color'");
				}
				return $hex(that);
			};
			d.srgb = function(that) {
				if(arguments.length < 1) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(that === void 0 || that === null) {
					throw new TypeError("'that' is not nullable");
				}
				else if(!Type.isClassInstance(that, Color)) {
					throw new TypeError("'that' is not of type 'Color'");
				}
				if(that._alpha === 1) {
					return "rgb(" + that._red + ", " + that._green + ", " + that._blue + ")";
				}
				else {
					return "rgba(" + that._red + ", " + that._green + ", " + that._blue + ", " + that._alpha + ")";
				}
			};
			return d;
		})();
		d["components"] = (() => {
			const d = new Dictionary();
			d["red"] = (() => {
				const d = new Dictionary();
				d["max"] = 255;
				return d;
			})();
			d["green"] = (() => {
				const d = new Dictionary();
				d["max"] = 255;
				return d;
			})();
			d["blue"] = (() => {
				const d = new Dictionary();
				d["max"] = 255;
				return d;
			})();
			return d;
		})();
		return d;
	})());
	Color.prototype.__ks_func_red_0 = function() {
		return this.getField("red");
	};
	Color.prototype.__ks_func_red_1 = function(value) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
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
		throw new SyntaxError("Wrong number of arguments");
	};
	Color.prototype.green = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_green_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_green_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	Color.prototype.blue = function() {
		if(arguments.length === 0) {
			return Color.prototype.__ks_func_blue_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Color.prototype.__ks_func_blue_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	let $static = (() => {
		const d = new Dictionary();
		d.black = Color.from("#000");
		d.gray = Color.from("#808080");
		d.white = Color.from("#fff");
		return d;
	})();
	return {
		Space: Space,
		Color: Color
	};
};
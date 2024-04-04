require("kaoscript/register");
const {Helper, OBJ, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("./_/._array.ks.j5k8r9.ksb")().__ks_Array;
	var Float = require("./_/._float.ks.j5k8r9.ksb")().Float;
	var Integer = require("./_/._integer.ks.j5k8r9.ksb")().Integer;
	var __ks_Math = require("./_/._math.ks.j5k8r9.ksb")().__ks_Math;
	var __ks_Number = require("./_/._number.ks.j5k8r9.ksb")().__ks_Number;
	var __ks_String = require("./_/._string.ks.j5k8r9.ksb")().__ks_String;
	const $spaces = new OBJ();
	const $aliases = new OBJ();
	const $components = new OBJ();
	const $formatters = new OBJ();
	const $names = (() => {
		const o = new OBJ();
		o["aliceblue"] = "f0f8ff";
		o["antiquewhite"] = "faebd7";
		o["aqua"] = "0ff";
		o["aquamarine"] = "7fffd4";
		o["azure"] = "f0ffff";
		o["beige"] = "f5f5dc";
		o["bisque"] = "ffe4c4";
		o["black"] = "000";
		o["blanchedalmond"] = "ffebcd";
		o["blue"] = "00f";
		o["blueviolet"] = "8a2be2";
		o["brown"] = "a52a2a";
		o["burlywood"] = "deb887";
		o["burntsienna"] = "ea7e5d";
		o["cadetblue"] = "5f9ea0";
		o["chartreuse"] = "7fff00";
		o["chocolate"] = "d2691e";
		o["coral"] = "ff7f50";
		o["cornflowerblue"] = "6495ed";
		o["cornsilk"] = "fff8dc";
		o["crimson"] = "dc143c";
		o["cyan"] = "0ff";
		o["darkblue"] = "00008b";
		o["darkcyan"] = "008b8b";
		o["darkgoldenrod"] = "b8860b";
		o["darkgray"] = "a9a9a9";
		o["darkgreen"] = "006400";
		o["darkgrey"] = "a9a9a9";
		o["darkkhaki"] = "bdb76b";
		o["darkmagenta"] = "8b008b";
		o["darkolivegreen"] = "556b2f";
		o["darkorange"] = "ff8c00";
		o["darkorchid"] = "9932cc";
		o["darkred"] = "8b0000";
		o["darksalmon"] = "e9967a";
		o["darkseagreen"] = "8fbc8f";
		o["darkslateblue"] = "483d8b";
		o["darkslategray"] = "2f4f4f";
		o["darkslategrey"] = "2f4f4f";
		o["darkturquoise"] = "00ced1";
		o["darkviolet"] = "9400d3";
		o["deeppink"] = "ff1493";
		o["deepskyblue"] = "00bfff";
		o["dimgray"] = "696969";
		o["dimgrey"] = "696969";
		o["dodgerblue"] = "1e90ff";
		o["firebrick"] = "b22222";
		o["floralwhite"] = "fffaf0";
		o["forestgreen"] = "228b22";
		o["fuchsia"] = "f0f";
		o["gainsboro"] = "dcdcdc";
		o["ghostwhite"] = "f8f8ff";
		o["gold"] = "ffd700";
		o["goldenrod"] = "daa520";
		o["gray"] = "808080";
		o["green"] = "008000";
		o["greenyellow"] = "adff2f";
		o["grey"] = "808080";
		o["honeydew"] = "f0fff0";
		o["hotpink"] = "ff69b4";
		o["indianred"] = "cd5c5c";
		o["indigo"] = "4b0082";
		o["ivory"] = "fffff0";
		o["khaki"] = "f0e68c";
		o["lavender"] = "e6e6fa";
		o["lavenderblush"] = "fff0f5";
		o["lawngreen"] = "7cfc00";
		o["lemonchiffon"] = "fffacd";
		o["lightblue"] = "add8e6";
		o["lightcoral"] = "f08080";
		o["lightcyan"] = "e0ffff";
		o["lightgoldenrodyellow"] = "fafad2";
		o["lightgray"] = "d3d3d3";
		o["lightgreen"] = "90ee90";
		o["lightgrey"] = "d3d3d3";
		o["lightpink"] = "ffb6c1";
		o["lightsalmon"] = "ffa07a";
		o["lightseagreen"] = "20b2aa";
		o["lightskyblue"] = "87cefa";
		o["lightslategray"] = "789";
		o["lightslategrey"] = "789";
		o["lightsteelblue"] = "b0c4de";
		o["lightyellow"] = "ffffe0";
		o["lime"] = "0f0";
		o["limegreen"] = "32cd32";
		o["linen"] = "faf0e6";
		o["magenta"] = "f0f";
		o["maroon"] = "800000";
		o["mediumaquamarine"] = "66cdaa";
		o["mediumblue"] = "0000cd";
		o["mediumorchid"] = "ba55d3";
		o["mediumpurple"] = "9370db";
		o["mediumseagreen"] = "3cb371";
		o["mediumslateblue"] = "7b68ee";
		o["mediumspringgreen"] = "00fa9a";
		o["mediumturquoise"] = "48d1cc";
		o["mediumvioletred"] = "c71585";
		o["midnightblue"] = "191970";
		o["mintcream"] = "f5fffa";
		o["mistyrose"] = "ffe4e1";
		o["moccasin"] = "ffe4b5";
		o["navajowhite"] = "ffdead";
		o["navy"] = "000080";
		o["oldlace"] = "fdf5e6";
		o["olive"] = "808000";
		o["olivedrab"] = "6b8e23";
		o["orange"] = "ffa500";
		o["orangered"] = "ff4500";
		o["orchid"] = "da70d6";
		o["palegoldenrod"] = "eee8aa";
		o["palegreen"] = "98fb98";
		o["paleturquoise"] = "afeeee";
		o["palevioletred"] = "db7093";
		o["papayawhip"] = "ffefd5";
		o["peachpuff"] = "ffdab9";
		o["peru"] = "cd853f";
		o["pink"] = "ffc0cb";
		o["plum"] = "dda0dd";
		o["powderblue"] = "b0e0e6";
		o["purple"] = "800080";
		o["red"] = "f00";
		o["rosybrown"] = "bc8f8f";
		o["royalblue"] = "4169e1";
		o["saddlebrown"] = "8b4513";
		o["salmon"] = "fa8072";
		o["sandybrown"] = "f4a460";
		o["seagreen"] = "2e8b57";
		o["seashell"] = "fff5ee";
		o["sienna"] = "a0522d";
		o["silver"] = "c0c0c0";
		o["skyblue"] = "87ceeb";
		o["slateblue"] = "6a5acd";
		o["slategray"] = "708090";
		o["slategrey"] = "708090";
		o["snow"] = "fffafa";
		o["springgreen"] = "00ff7f";
		o["steelblue"] = "4682b4";
		o["tan"] = "d2b48c";
		o["teal"] = "008080";
		o["thistle"] = "d8bfd8";
		o["tomato"] = "ff6347";
		o["turquoise"] = "40e0d0";
		o["violet"] = "ee82ee";
		o["wheat"] = "f5deb3";
		o["white"] = "fff";
		o["whitesmoke"] = "f5f5f5";
		o["yellow"] = "ff0";
		o["yellowgreen"] = "9acd32";
		return o;
	})();
	function $blend() {
		return $blend.__ks_rt(this, arguments);
	};
	$blend.__ks_0 = function(x, y, percentage) {
		return ((1 - percentage) * x) + (percentage * y);
	};
	$blend.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return $blend.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	function $binder() {
		return $binder.__ks_rt(this, arguments);
	};
	$binder.__ks_0 = function(last, components, first, firstArgs) {
		const that = first(...firstArgs);
		const lastArgs = (() => {
			const a = [];
			for(const name in components) {
				const component = components[name];
				a.push(that[component.field]);
			}
			return a;
		})();
		lastArgs.push(that);
		return last(...lastArgs);
	};
	$binder.__ks_rt = function(that, args) {
		const t0 = Type.isFunction;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 3) {
			if(t0(args[0]) && t1(args[1]) && t0(args[2]) && Helper.isVarargs(args, 0, args.length - 3, t1, pts = [3], 0) && te(pts, 1)) {
				return $binder.__ks_0.call(that, args[0], args[1], args[2], Helper.getVarargs(args, 3, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	let $caster = Helper.namespace(function() {
		function alpha() {
			return alpha.__ks_rt(this, arguments);
		};
		alpha.__ks_0 = function(n = null, percentage) {
			if(percentage === void 0 || percentage === null) {
				percentage = false;
			}
			let i = Float.parse.__ks_0(n);
			return Number.isNaN(i) ? 1 : __ks_Number.__ks_func_round_0.call(__ks_Number.__ks_func_limit_0.call(percentage ? i / 100 : i, 0, 1), 3);
		};
		alpha.__ks_rt = function(that, args) {
			const t0 = Type.any;
			const t1 = value => Type.isBoolean(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 2) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
					return alpha.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		};
		function ff() {
			return ff.__ks_rt(this, arguments);
		};
		ff.__ks_0 = function(n) {
			return __ks_Number.__ks_func_round_0.call(__ks_Number.__ks_func_limit_0.call(Float.parse.__ks_0(n), 0, 255));
		};
		ff.__ks_rt = function(that, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return ff.__ks_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		};
		function percentage() {
			return percentage.__ks_rt(this, arguments);
		};
		percentage.__ks_0 = function(n) {
			return __ks_Number.__ks_func_round_0.call(__ks_Number.__ks_func_limit_0.call(Float.parse.__ks_0(n), 0, 100), 1);
		};
		percentage.__ks_rt = function(that, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return percentage.__ks_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		};
		return {
			alpha,
			ff,
			percentage
		};
	});
	function $component() {
		return $component.__ks_rt(this, arguments);
	};
	$component.__ks_0 = function(component, name, space) {
		component.field = "_" + name;
		$spaces[space].components[name] = component;
		if(!Type.isValue($components[name])) {
			$components[name] = (() => {
				const o = new OBJ();
				o.field = component.field;
				o.spaces = new OBJ();
				o.families = [];
				return o;
			})();
		}
		$components[name].families.push(space);
		$components[name].spaces[space] = true;
	};
	$component.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isString;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t1(args[2])) {
				return $component.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	function $convert() {
		return $convert.__ks_rt(this, arguments);
	};
	$convert.__ks_0 = function(that, space, result) {
		if(result === void 0 || result === null) {
			result = (() => {
				const o = new OBJ();
				o._alpha = 0;
				return o;
			})();
		}
		const s = $spaces[that._space];
		if(Type.isValue(s.converters[space])) {
			const args = (() => {
				const a = [];
				for(const name in s.components) {
					const component = s.components[name];
					a.push(that[component.field]);
				}
				return a;
			})();
			args.push(result);
			s.converters[space](...args);
			result._space = space;
			return result;
		}
		else {
			throw new Error("It can't convert a color from '" + that._space + "' to '" + space + "' spaces.");
		}
	};
	$convert.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Color);
		const t1 = value => Type.isEnumInstance(value, Space);
		const t2 = value => Type.isObject(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 2 && args.length <= 3) {
			if(t0(args[0]) && t1(args[1]) && Helper.isVarargs(args, 0, 1, t2, pts = [2], 0) && te(pts, 1)) {
				return $convert.__ks_0.call(that, args[0], args[1], Helper.getVararg(args, 2, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function $find() {
		return $find.__ks_rt(this, arguments);
	};
	$find.__ks_0 = function(from, to) {
		for(const name in $spaces[from].converters) {
			if(Type.isValue($spaces[name].converters[to])) {
				$spaces[from].converters[to] = (__ks_0) => $binder($spaces[name].converters[to], $spaces[name].components, $spaces[from].converters[name], ...__ks_0);
				return;
			}
		}
	};
	$find.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return $find.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function $from() {
		return $from.__ks_rt(this, arguments);
	};
	$from.__ks_0 = function(that, args) {
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
			for(const name in $parsers) {
				const parse = $parsers[name];
				if(parse(that, args) === true) {
					return that;
				}
			}
		}
		that._dummy = true;
		return that;
	};
	$from.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Color);
		const t1 = Type.isArray;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return $from.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function $hex() {
		return $hex.__ks_rt(this, arguments);
	};
	$hex.__ks_0 = function(that) {
		const chars = "0123456789abcdef";
		const r1 = that._red >> 4;
		const g1 = that._green >> 4;
		const b1 = that._blue >> 4;
		const r2 = that._red & 15;
		const g2 = that._green & 15;
		const b2 = that._blue & 15;
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
	};
	$hex.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Color);
		if(args.length === 1) {
			if(t0(args[0])) {
				return $hex.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const $parsers = (() => {
		const o = new OBJ();
		o.srgb = Helper.function(function(that, args) {
			if(args.length === 1) {
				if(Type.isNumber(args[0])) {
					that._space = Space.SRGB;
					that._alpha = $caster.alpha.__ks_0(((args[0] >> 24) & 255) / 255);
					that._red = (args[0] >> 16) & 255;
					that._green = (args[0] >> 8) & 255;
					that._blue = args[0] & 255;
					return true;
				}
				else if(Type.isArray(args[0])) {
					that._space = Space.SRGB;
					that._alpha = (args[0].length === 4) ? $caster.alpha.__ks_0(args[0][3]) : 1;
					that._red = $caster.ff(args[0][0]);
					that._green = $caster.ff(args[0][1]);
					that._blue = $caster.ff(args[0][2]);
					return true;
				}
				else if(Type.isObject(args[0])) {
					if(Type.isValue(args[0].r) && Type.isValue(args[0].g) && Type.isValue(args[0].b)) {
						that._space = Space.SRGB;
						that._alpha = $caster.alpha.__ks_0(args[0].a);
						that._red = $caster.ff.__ks_0(args[0].r);
						that._green = $caster.ff.__ks_0(args[0].g);
						that._blue = $caster.ff.__ks_0(args[0].b);
						return true;
					}
					if(Type.isValue(args[0].red) && Type.isValue(args[0].green) && Type.isValue(args[0].blue)) {
						that._space = Space.SRGB;
						that._alpha = $caster.alpha.__ks_0(args[0].alpha);
						that._red = $caster.ff.__ks_0(args[0].red);
						that._green = $caster.ff.__ks_0(args[0].green);
						that._blue = $caster.ff.__ks_0(args[0].blue);
						return true;
					}
				}
				else if(Type.isString(args[0])) {
					let color = __ks_String.__ks_func_lower_0.call(args[0]).replace(/[^a-z0-9,.()#%]/g, "");
					if("transparent" === color) {
						that._alpha = that._red = that._green = that._blue = 0;
						return true;
					}
					else if("rand" === color) {
						const c = (Math.random() * 16777215) | 0;
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
					let match = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color);
					if(Type.isValue(match)) {
						that._space = Space.SRGB;
						that._red = Integer.parse.__ks_0(match[1], 16);
						that._green = Integer.parse.__ks_0(match[2], 16);
						that._blue = Integer.parse.__ks_0(match[3], 16);
						that._alpha = $caster.alpha.__ks_0(Integer.parse.__ks_0(match[4], 16) / 255);
						return true;
					}
					else if(Type.isValue((match = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color)))) {
						that._space = Space.SRGB;
						that._red = Integer.parse.__ks_0(match[1], 16);
						that._green = Integer.parse.__ks_0(match[2], 16);
						that._blue = Integer.parse.__ks_0(match[3], 16);
						that._alpha = 1;
						return true;
					}
					else if(Type.isValue((match = /^#?([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)))) {
						that._space = Space.SRGB;
						that._red = Integer.parse.__ks_0(Operator.add(match[1], match[1]), 16);
						that._green = Integer.parse.__ks_0(Operator.add(match[2], match[2]), 16);
						that._blue = Integer.parse.__ks_0(Operator.add(match[3], match[3]), 16);
						that._alpha = $caster.alpha.__ks_0(Integer.parse.__ks_0(Operator.add(match[4], match[4]), 16) / 255);
						return true;
					}
					else if(Type.isValue((match = /^#?([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)))) {
						that._space = Space.SRGB;
						that._red = Integer.parse.__ks_0(Operator.add(match[1], match[1]), 16);
						that._green = Integer.parse.__ks_0(Operator.add(match[2], match[2]), 16);
						that._blue = Integer.parse.__ks_0(Operator.add(match[3], match[3]), 16);
						that._alpha = 1;
						return true;
					}
					else if(Type.isValue((match = /^rgba?\((\d{1,3}),(\d{1,3}),(\d{1,3})(,([0-9.]+)(\%)?)?\)$/.exec(color)))) {
						that._space = Space.SRGB;
						that._red = $caster.ff(match[1]);
						that._green = $caster.ff(match[2]);
						that._blue = $caster.ff(match[3]);
						that._alpha = $caster.alpha.__ks_0(match[5], Type.isValue(match[6]));
						return true;
					}
					else if(Type.isValue((match = /^rgba?\(([0-9.]+\%),([0-9.]+\%),([0-9.]+\%)(,([0-9.]+)(\%)?)?\)$/.exec(color)))) {
						that._space = Space.SRGB;
						that._red = Math.round(2.55 * $caster.percentage(match[1]));
						that._green = Math.round(2.55 * $caster.percentage(match[2]));
						that._blue = Math.round(2.55 * $caster.percentage(match[3]));
						that._alpha = $caster.alpha.__ks_0(match[5], Type.isValue(match[6]));
						return true;
					}
					else if(Type.isValue((match = /^rgba?\(#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2}),([0-9.]+)(\%)?\)$/.exec(color)))) {
						that._space = Space.SRGB;
						that._red = Integer.parse.__ks_0(match[1], 16);
						that._green = Integer.parse.__ks_0(match[2], 16);
						that._blue = Integer.parse.__ks_0(match[3], 16);
						that._alpha = $caster.alpha.__ks_0(match[4], Type.isValue(match[5]));
						return true;
					}
					else if(Type.isValue((match = /^rgba\(#?([0-9a-f])([0-9a-f])([0-9a-f]),([0-9.]+)(\%)?\)$/.exec(color)))) {
						that._space = Space.SRGB;
						that._red = Integer.parse.__ks_0(Operator.add(match[1], match[1]), 16);
						that._green = Integer.parse.__ks_0(Operator.add(match[2], match[2]), 16);
						that._blue = Integer.parse.__ks_0(Operator.add(match[3], match[3]), 16);
						that._alpha = $caster.alpha.__ks_0(match[4], Type.isValue(match[5]));
						return true;
					}
					else if(Type.isValue((match = /^(\d{1,3}),(\d{1,3}),(\d{1,3})(?:,([0-9.]+))?$/.exec(color)))) {
						that._space = Space.SRGB;
						that._red = $caster.ff(match[1]);
						that._green = $caster.ff(match[2]);
						that._blue = $caster.ff(match[3]);
						that._alpha = $caster.alpha.__ks_0(match[4]);
						return true;
					}
				}
			}
			else if(args.length >= 3) {
				that._space = Space.SRGB;
				that._alpha = (args.length >= 4) ? $caster.alpha.__ks_0(args[3]) : 1;
				that._red = $caster.ff(args[0]);
				that._green = $caster.ff(args[1]);
				that._blue = $caster.ff(args[2]);
				return true;
			}
			return false;
		}, (that, fn, ...args) => {
			const t0 = value => Type.isClassInstance(value, Color);
			const t1 = Type.isArray;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return fn.call(null, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		});
		o.gray = Helper.function(function(that, args) {
			if(args.length >= 1) {
				if(Number.isFinite(Float.parse.__ks_0(args[0])) === true) {
					that._space = Space.SRGB;
					that._red = that._green = that._blue = $caster.ff(args[0]);
					that._alpha = (args.length >= 2) ? $caster.alpha.__ks_0(args[1]) : 1;
					return true;
				}
				else if(Type.isString(args[0])) {
					const color = __ks_String.__ks_func_lower_0.call(args[0]).replace(/[^a-z0-9,.()#%]/g, "");
					let match = /^gray\((\d{1,3})(?:,([0-9.]+)(\%)?)?\)$/.exec(color);
					if(Type.isValue(match)) {
						that._space = Space.SRGB;
						that._red = that._green = that._blue = $caster.ff(match[1]);
						that._alpha = $caster.alpha.__ks_0(match[2], Type.isValue(match[3]));
						return true;
					}
					else if(Type.isValue((match = /^gray\(([0-9.]+\%)(?:,([0-9.]+)(\%)?)?\)$/.exec(color)))) {
						that._space = Space.SRGB;
						that._red = that._green = that._blue = Math.round(2.55 * $caster.percentage(match[1]));
						that._alpha = $caster.alpha.__ks_0(match[2], Type.isValue(match[3]));
						return true;
					}
				}
			}
			return false;
		}, (that, fn, ...args) => {
			const t0 = value => Type.isClassInstance(value, Color);
			const t1 = Type.isArray;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return fn.call(null, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		});
		return o;
	})();
	function $space() {
		return $space.__ks_rt(this, arguments);
	};
	$space.__ks_0 = function(name) {
		$spaces[name] = Type.isValue($spaces[name]) ? $spaces[name] : (() => {
			const o = new OBJ();
			o.alias = new OBJ();
			o.converters = new OBJ();
			o.components = new OBJ();
			return o;
		})();
	};
	$space.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return $space.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const Space = Helper.enum(String, 0);
	class Color {
		static __ks_new_0(...args) {
			const o = Object.create(Color.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._dummy = false;
			this._space = Space.SRGB;
			this._alpha = 0;
			this._red = 0;
			this._green = 0;
			this._blue = 0;
		}
		__ks_cons_0(args) {
			$from.__ks_0(this, args);
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return Color.prototype.__ks_cons_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		alpha() {
			return this.__ks_func_alpha_rt.call(null, this, this, arguments);
		}
		__ks_func_alpha_0() {
			return this._alpha;
		}
		__ks_func_alpha_1(value) {
			this._alpha = $caster.alpha.__ks_0(value);
			return this;
		}
		__ks_func_alpha_rt(that, proto, args) {
			const t0 = value => Type.isNumber(value) || Type.isString(value);
			if(args.length === 0) {
				return proto.__ks_func_alpha_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_alpha_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		blend() {
			return this.__ks_func_blend_rt.call(null, this, this, arguments);
		}
		__ks_func_blend_0(color, percentage, space, alpha) {
			if(space === void 0 || space === null) {
				space = Space.SRGB;
			}
			if(alpha === void 0 || alpha === null) {
				alpha = false;
			}
			if(alpha) {
				const w = (percentage * 2) - 1;
				const a = color._alpha - this._alpha;
				this._alpha = __ks_Number.__ks_func_round_0.call($blend.__ks_0(this._alpha, color._alpha, percentage), 2);
				if((w * a) === -1) {
					percentage = w;
				}
				else {
					percentage = (w + a) / (1 + (w * a));
				}
			}
			space = Type.isValue($aliases[space]) ? $aliases[space] : space;
			this.__ks_func_space_1(space);
			color = color.__ks_func_like_0(space);
			const components = $spaces[space].components;
			for(const name in components) {
				const component = components[name];
				if(component.loop === true) {
					let d = Math.abs(Operator.subtraction(this[component.field], color[component.field]));
					if(Operator.gt(d, component.half)) {
						d = component.mod - d;
					}
					this[component.field] = __ks_Number._im_round(Operator.remainder(this[component.field] + (d * percentage), component.mod), component.round);
				}
				else {
					this[component.field] = __ks_Number._im_round(__ks_Number._im_limit($blend(this[component.field], color[component.field], percentage), component.min, component.max), component.round);
				}
			}
			return this;
		}
		__ks_func_blend_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Color);
			const t1 = Type.isNumber;
			const t2 = value => Type.isEnumInstance(value, Space) || Type.isNull(value);
			const t3 = value => Type.isBoolean(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 2 && args.length <= 4) {
				if(t0(args[0]) && t1(args[1]) && Helper.isVarargs(args, 0, 1, t2, pts = [2], 0) && Helper.isVarargs(args, 0, 1, t3, pts, 1) && te(pts, 2)) {
					return proto.__ks_func_blend_0.call(that, args[0], args[1], Helper.getVararg(args, 2, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		}
		clearer() {
			return this.__ks_func_clearer_rt.call(null, this, this, arguments);
		}
		__ks_func_clearer_0(value) {
			if(Type.isString(value) && (value.endsWith("%") === true)) {
				return this.__ks_func_alpha_1(this._alpha * ((100 - __ks_String.__ks_func_toFloat_0.call(value)) / 100));
			}
			else {
				return this.__ks_func_alpha_1(this._alpha - (Type.isString(value) ? __ks_String.__ks_func_toFloat_0.call(value) : __ks_Number.__ks_func_toFloat_0.call(value)));
			}
		}
		__ks_func_clearer_rt(that, proto, args) {
			const t0 = value => Type.isNumber(value) || Type.isString(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_clearer_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		clone() {
			return this.__ks_func_clone_rt.call(null, this, this, arguments);
		}
		__ks_func_clone_0() {
			return this.__ks_func_copy_0(Color.__ks_new_0([]));
		}
		__ks_func_clone_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_clone_0.call(that);
			}
			throw Helper.badArgs();
		}
		contrast() {
			return this.__ks_func_contrast_rt.call(null, this, this, arguments);
		}
		__ks_func_contrast_0(color) {
			const a = this._alpha;
			if(a === 1) {
				if(color._alpha !== 1) {
					color = color.__ks_func_clone_0().__ks_func_blend_0(this, 0.5, Space.SRGB, true);
				}
				const l1 = this.__ks_func_luminance_0() + 0.05;
				const l2 = color.__ks_func_luminance_0() + 0.05;
				let ratio = l1 / l2;
				if(l2 > l1) {
					ratio = 1 / ratio;
				}
				ratio = __ks_Number.__ks_func_round_0.call(ratio, 2);
				return (() => {
					const o = new OBJ();
					o.ratio = ratio;
					o.error = 0;
					o.min = ratio;
					o.max = ratio;
					return o;
				})();
			}
			else {
				const black = this.__ks_func_clone_0().blend($static.black, 0.5, Space.SRGB, true).contrast(color).ratio;
				const white = this.__ks_func_clone_0().blend($static.white, 0.5, Space.SRGB, true).contrast(color).ratio;
				const max = Math.max(black, white);
				const closest = Color.__ks_new_0([__ks_Number.__ks_func_limit_0.call((color._red - (this._red * a)) / (1 - a), 0, 255), __ks_Number.__ks_func_limit_0.call((color._green - (this._green * a)) / (1 - a), 0, 255), __ks_Number.__ks_func_limit_0.call((color._blue - (this._blue * a)) / (1 - a), 0, 255)]);
				const min = this.__ks_func_clone_0().__ks_func_blend_0(closest, 0.5, Space.SRGB, true).__ks_func_contrast_0(color).ratio;
				return (() => {
					const o = new OBJ();
					o.ratio = __ks_Number.__ks_func_round_0.call((min + max) / 2, 2);
					o.error = __ks_Number.__ks_func_round_0.call((max - min) / 2, 2);
					o.min = min;
					o.max = max;
					return o;
				})();
			}
		}
		__ks_func_contrast_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Color);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_contrast_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		copy() {
			return this.__ks_func_copy_rt.call(null, this, this, arguments);
		}
		__ks_func_copy_0(target) {
			const s1 = this._space;
			const s2 = target._space;
			this.__ks_func_space_1(Space.SRGB);
			target.__ks_func_space_1(Space.SRGB);
			target._red = this._red;
			target._green = this._green;
			target._blue = this._blue;
			target._alpha = this._alpha;
			target._dummy = this._dummy;
			this.__ks_func_space_1(s1);
			target.__ks_func_space_1(s2);
			return target;
		}
		__ks_func_copy_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Color);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_copy_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		distance() {
			return this.__ks_func_distance_rt.call(null, this, this, arguments);
		}
		__ks_func_distance_0(color) {
			const that = this.__ks_func_like_0(Space.SRGB);
			color = color.__ks_func_like_0(Space.SRGB);
			return Math.sqrt((3 * (color._red - that._red) * (color._red - that._red)) + (4 * (color._green - that._green) * (color._green - that._green)) + (2 * (color._blue - that._blue) * (color._blue - that._blue)));
		}
		__ks_func_distance_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Color);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_distance_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		equals() {
			return this.__ks_func_equals_rt.call(null, this, this, arguments);
		}
		__ks_func_equals_0(color) {
			return this.__ks_func_hex_0() === color.__ks_func_hex_0();
		}
		__ks_func_equals_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Color);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_equals_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		format() {
			return this.__ks_func_format_rt.call(null, this, this, arguments);
		}
		__ks_func_format_0(format) {
			if(format === void 0 || format === null) {
				format = this._space.value;
			}
			let __ks_format_1 = $formatters[format];
			if(Type.isValue(__ks_format_1)) {
				return __ks_format_1.formatter(Type.isValue(__ks_format_1.space) ? this.like(__ks_format_1.space) : this);
			}
			else {
				return false;
			}
		}
		__ks_func_format_rt(that, proto, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return proto.__ks_func_format_0.call(that, Helper.getVararg(args, 0, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
		from() {
			return this.__ks_func_from_rt.call(null, this, this, arguments);
		}
		__ks_func_from_0(args) {
			return $from.__ks_0(this, args);
		}
		__ks_func_from_rt(that, proto, args) {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_from_0.call(that, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		getField() {
			return this.__ks_func_getField_rt.call(null, this, this, arguments);
		}
		__ks_func_getField_0(name) {
			const component = $components[name];
			if(Type.isValue(component.spaces[this._space])) {
				return this[component.field];
			}
			else if(Operator.gt(component.families.length, 1)) {
				throw new Error(Helper.concatString("The component '", name, "' has a conflict between the spaces '", component.families.join("', '"), "'"));
			}
			else {
				return this.like(component.families[0])[component.field];
			}
		}
		__ks_func_getField_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_getField_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		gradient() {
			return this.__ks_func_gradient_rt.call(null, this, this, arguments);
		}
		__ks_func_gradient_0(endColor, length) {
			const gradient = [this];
			if(length > 0) {
				this.__ks_func_space_1(Space.SRGB);
				endColor.__ks_func_space_1(Space.SRGB);
				length += 1;
				const red = endColor._red - this._red;
				const green = endColor._green - this._green;
				const blue = endColor._blue - this._blue;
				let __ks_0, __ks_1, __ks_2, __ks_3;
				[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoopBounds(0, "", 1, "", length, Infinity, "", 1);
				for(let __ks_4 = __ks_0, i; __ks_4 < __ks_1; __ks_4 += __ks_2) {
					i = __ks_3(__ks_4);
					const offset = i / length;
					const color = this.__ks_func_clone_0();
					color._red += Math.round(red * offset);
					color._green += Math.round(green * offset);
					color._blue += Math.round(blue * offset);
					gradient.push(color);
				}
			}
			gradient.push(endColor);
			return gradient;
		}
		__ks_func_gradient_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Color);
			const t1 = Type.isNumber;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return proto.__ks_func_gradient_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
		greyscale() {
			return this.__ks_func_greyscale_rt.call(null, this, this, arguments);
		}
		__ks_func_greyscale_0(model) {
			if(model === void 0 || model === null) {
				model = "BT709";
			}
			this.__ks_func_space_1(Space.SRGB);
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
		__ks_func_greyscale_rt(that, proto, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return proto.__ks_func_greyscale_0.call(that, Helper.getVararg(args, 0, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
		hex() {
			return this.__ks_func_hex_rt.call(null, this, this, arguments);
		}
		__ks_func_hex_0() {
			return $hex(this.__ks_func_like_0(Space.SRGB));
		}
		__ks_func_hex_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_hex_0.call(that);
			}
			throw Helper.badArgs();
		}
		isBlack() {
			return this.__ks_func_isBlack_rt.call(null, this, this, arguments);
		}
		__ks_func_isBlack_0() {
			const that = this.__ks_func_like_0(Space.SRGB);
			return (that._red === 0) && (that._green === 0) && (that._blue === 0);
		}
		__ks_func_isBlack_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_isBlack_0.call(that);
			}
			throw Helper.badArgs();
		}
		isTransparent() {
			return this.__ks_func_isTransparent_rt.call(null, this, this, arguments);
		}
		__ks_func_isTransparent_0() {
			if(this._alpha === 0) {
				const that = this.__ks_func_like_0(Space.SRGB);
				return (that._red === 0) && (that._green === 0) && (that._blue === 0);
			}
			else {
				return false;
			}
		}
		__ks_func_isTransparent_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_isTransparent_0.call(that);
			}
			throw Helper.badArgs();
		}
		isWhite() {
			return this.__ks_func_isWhite_rt.call(null, this, this, arguments);
		}
		__ks_func_isWhite_0() {
			const that = this.__ks_func_like_0(Space.SRGB);
			return (that._red === 255) && (that._green === 255) && (that._blue === 255);
		}
		__ks_func_isWhite_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_isWhite_0.call(that);
			}
			throw Helper.badArgs();
		}
		like() {
			return this.__ks_func_like_rt.call(null, this, this, arguments);
		}
		__ks_func_like_0(space) {
			space = Type.isValue($aliases[space]) ? $aliases[space] : space;
			let value = Space(space);
			if(Type.isValue(value)) {
				if((this._space !== value) && Type.isValue($spaces[this._space].converters[space])) {
					return $convert.__ks_0(this, value);
				}
			}
			return this;
		}
		__ks_func_like_1(str) {
			let space = Space(Type.isValue($aliases[str]) ? $aliases[str] : str);
			if(Type.isValue(space)) {
				return this.__ks_func_like_0(space);
			}
			else {
				return this;
			}
		}
		__ks_func_like_rt(that, proto, args) {
			const t0 = value => Type.isEnumInstance(value, Space);
			const t1 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_like_0.call(that, args[0]);
				}
				if(t1(args[0])) {
					return proto.__ks_func_like_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		luminance() {
			return this.__ks_func_luminance_rt.call(null, this, this, arguments);
		}
		__ks_func_luminance_0() {
			const that = this.__ks_func_like_0(Space.SRGB);
			let r = that._red / 255;
			r = (r < 0.03928) ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
			let g = that._green / 255;
			g = (g < 0.03928) ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
			let b = that._blue / 255;
			b = (b < 0.03928) ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);
			return (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
		}
		__ks_func_luminance_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_luminance_0.call(that);
			}
			throw Helper.badArgs();
		}
		negative() {
			return this.__ks_func_negative_rt.call(null, this, this, arguments);
		}
		__ks_func_negative_0() {
			this.__ks_func_space_1(Space.SRGB);
			this._red ^= 255;
			this._green ^= 255;
			this._blue ^= 255;
			return this;
		}
		__ks_func_negative_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_negative_0.call(that);
			}
			throw Helper.badArgs();
		}
		opaquer() {
			return this.__ks_func_opaquer_rt.call(null, this, this, arguments);
		}
		__ks_func_opaquer_0(value) {
			if(Type.isString(value) && (value.endsWith("%") === true)) {
				return this.__ks_func_alpha_1(this._alpha * ((100 + __ks_String.__ks_func_toFloat_0.call(value)) / 100));
			}
			else {
				return this.__ks_func_alpha_1(this._alpha + (Type.isString(value) ? __ks_String.__ks_func_toFloat_0.call(value) : __ks_Number.__ks_func_toFloat_0.call(value)));
			}
		}
		__ks_func_opaquer_rt(that, proto, args) {
			const t0 = value => Type.isNumber(value) || Type.isString(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_opaquer_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		readable() {
			return this.__ks_func_readable_rt.call(null, this, this, arguments);
		}
		__ks_func_readable_0(color, tripleA) {
			if(tripleA === void 0 || tripleA === null) {
				tripleA = false;
			}
			if(tripleA) {
				return Operator.gte(this.__ks_func_contrast_0(color).ratio, 7);
			}
			else {
				return Operator.gte(this.__ks_func_contrast_0(color).ratio, 4.5);
			}
		}
		__ks_func_readable_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Color);
			const t1 = value => Type.isBoolean(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 2) {
				if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && te(pts, 1)) {
					return proto.__ks_func_readable_0.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
		scheme() {
			return this.__ks_func_scheme_rt.call(null, this, this, arguments);
		}
		__ks_func_scheme_0(functions) {
			return (() => {
				const a = [];
				for(let __ks_1 = 0, __ks_0 = functions.length, fn; __ks_1 < __ks_0; ++__ks_1) {
					fn = functions[__ks_1];
					a.push(fn(this.__ks_func_clone_0()));
				}
				return a;
			})();
		}
		__ks_func_scheme_rt(that, proto, args) {
			const t0 = value => Type.isArray(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_scheme_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		setField() {
			return this.__ks_func_setField_rt.call(null, this, this, arguments);
		}
		__ks_func_setField_0(name, value) {
			let component = $components[name];
			if(Type.isValue(component.spaces[this._space])) {
				component = $spaces[this._space].components[name];
			}
			else if(Operator.gt(component.families.length, 1)) {
				throw new Error(Helper.concatString("The component '", name, "' has a conflict between the spaces '", component.families.join("', '"), "'"));
			}
			else {
				this.space(component.families[0]);
				component = $spaces[component.families[0]].components[name];
			}
			if(Type.isValue(component.parser)) {
				this[component.field] = component.parser(value);
			}
			else if(component.loop === true) {
				this[component.field] = __ks_Number._im_round(__ks_Number._im_mod(Type.isNumber(value) ? __ks_Number.__ks_func_toFloat_0.call(value) : __ks_String.__ks_func_toFloat_0.call(value), component.mod), component.round);
			}
			else {
				this[component.field] = __ks_Number._im_round(__ks_Number._im_limit(Type.isNumber(value) ? __ks_Number.__ks_func_toFloat_0.call(value) : __ks_String.__ks_func_toFloat_0.call(value), component.min, component.max), component.round);
			}
			return this;
		}
		__ks_func_setField_rt(that, proto, args) {
			const t0 = Type.isValue;
			const t1 = value => Type.isNumber(value) || Type.isString(value);
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return proto.__ks_func_setField_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
		shade() {
			return this.__ks_func_shade_rt.call(null, this, this, arguments);
		}
		__ks_func_shade_0(percentage) {
			return this.blend($static.black, percentage);
		}
		__ks_func_shade_rt(that, proto, args) {
			const t0 = Type.isNumber;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_shade_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		space() {
			return this.__ks_func_space_rt.call(null, this, this, arguments);
		}
		__ks_func_space_0() {
			return this._space;
		}
		__ks_func_space_1(space) {
			if((this._space !== space) && Type.isValue($spaces[this._space].converters[space])) {
				$convert.__ks_0(this, space, this);
			}
			return this;
		}
		__ks_func_space_2(str) {
			let space = Space(Type.isValue($aliases[str]) ? $aliases[str] : str);
			if(Type.isValue(space)) {
				return this.__ks_func_space_1(space);
			}
			let component = $components[str];
			if(Type.isValue(component)) {
				if(Type.isValue($spaces[this._space].components[str])) {
					return this;
				}
				else if(component.families.length === 1) {
					return this.space(component.families[0]);
				}
				else {
					throw new Error(Helper.concatString("The component '", str, "' has a conflict between the spaces '", component.families.join("', '"), "'"));
				}
			}
			throw new Error("It can't convert a color from '" + this._space + "' to '" + str + "' spaces.");
		}
		__ks_func_space_rt(that, proto, args) {
			const t0 = value => Type.isEnumInstance(value, Space);
			const t1 = Type.isString;
			if(args.length === 0) {
				return proto.__ks_func_space_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_space_1.call(that, args[0]);
				}
				if(t1(args[0])) {
					return proto.__ks_func_space_2.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		tint() {
			return this.__ks_func_tint_rt.call(null, this, this, arguments);
		}
		__ks_func_tint_0(percentage) {
			return this.blend($static.white, percentage);
		}
		__ks_func_tint_rt(that, proto, args) {
			const t0 = Type.isNumber;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_tint_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		tone() {
			return this.__ks_func_tone_rt.call(null, this, this, arguments);
		}
		__ks_func_tone_0(percentage) {
			return this.blend($static.gray, percentage);
		}
		__ks_func_tone_rt(that, proto, args) {
			const t0 = Type.isNumber;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_tone_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		red() {
			return this.__ks_func_red_rt.call(null, this, this, arguments);
		}
		__ks_func_red_0() {
			return this.__ks_func_getField_0("red");
		}
		__ks_func_red_1(value) {
			return this.setField("red", value);
		}
		__ks_func_red_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_red_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_red_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		green() {
			return this.__ks_func_green_rt.call(null, this, this, arguments);
		}
		__ks_func_green_0() {
			return this.__ks_func_getField_0("green");
		}
		__ks_func_green_1(value) {
			return this.setField("green", value);
		}
		__ks_func_green_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_green_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_green_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		blue() {
			return this.__ks_func_blue_rt.call(null, this, this, arguments);
		}
		__ks_func_blue_0() {
			return this.__ks_func_getField_0("blue");
		}
		__ks_func_blue_1(value) {
			return this.setField("blue", value);
		}
		__ks_func_blue_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_blue_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_blue_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_addSpace_0(space) {
			const spaces = Object.keys($spaces);
			$space(space.name);
			if(Type.isValue(space.parser)) {
				$parsers[space.name] = space.parser;
			}
			if(Type.isValue(space.formatter)) {
				$formatters[space.name] = (() => {
					const o = new OBJ();
					o.space = space.name;
					o.formatter = space.formatter;
					return o;
				})();
			}
			else if(Type.isValue(space.formatters)) {
				for(const name in space.formatters) {
					const formatter = space.formatters[name];
					$formatters[name] = (() => {
						const o = new OBJ();
						o.space = space.name;
						o.formatter = formatter;
						return o;
					})();
				}
			}
			if(Type.isValue(space.alias)) {
				for(let __ks_1 = 0, __ks_0 = space.alias.length, alias; __ks_1 < __ks_0; ++__ks_1) {
					alias = space.alias[__ks_1];
					$spaces[space.name].alias[alias] = true;
					$aliases[alias] = Space(space.name);
				}
				if(Type.isValue($parsers[space.name])) {
					for(let __ks_1 = 0, __ks_0 = space.alias.length, alias; __ks_1 < __ks_0; ++__ks_1) {
						alias = space.alias[__ks_1];
						$parsers[alias] = $parsers[space.name];
					}
				}
				if(Type.isValue($formatters[space.name])) {
					for(let __ks_1 = 0, __ks_0 = space.alias.length, alias; __ks_1 < __ks_0; ++__ks_1) {
						alias = space.alias[__ks_1];
						$formatters[alias] = $formatters[space.name];
					}
				}
			}
			if(Type.isValue(space.converters)) {
				if(Type.isValue(space.converters.from)) {
					for(const name in space.converters.from) {
						const converter = space.converters.from[name];
						if(!Type.isValue($spaces[name])) {
							$space.__ks_0(name);
						}
						$spaces[name].converters[space.name] = converter;
					}
				}
				if(Type.isValue(space.converters.to)) {
					for(const name in space.converters.to) {
						const converter = space.converters.to[name];
						$spaces[space.name].converters[name] = converter;
					}
				}
			}
			for(let __ks_1 = 0, __ks_0 = Helper.length(spaces), name; __ks_1 < __ks_0; ++__ks_1) {
				name = spaces[__ks_1];
				if(!Type.isValue($spaces[name].converters[space.name])) {
					$find(name, space.name);
				}
				if(!Type.isValue($spaces[space.name].converters[name])) {
					$find(space.name, name);
				}
			}
			if(Type.isValue(space.components)) {
				for(const name in space.components) {
					const component = space.components[name];
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
							component.mod = Operator.add(component.max, 1);
							component.half = Operator.division(component.mod, 2);
						}
						$component(component, name, space.name);
					}
				}
			}
		}
		static addSpace() {
			const t0 = Type.isObject;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Color.__ks_sttc_addSpace_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_from_0(args) {
			const color = $from.__ks_0(Color.__ks_new_0([]), args);
			return color._dummy ? false : color;
		}
		static from() {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
			let pts;
			if(Helper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
				return Color.__ks_sttc_from_0(Helper.getVarargs(arguments, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_greyscale_0(args) {
			let model = __ks_Array.__ks_func_last_0.call(args);
			if((model === "BT709") || (model === "average") || (model === "lightness") || (model === "Y") || (model === "RMY")) {
				args.pop();
			}
			else {
				model = null;
			}
			const color = $from.__ks_0(Color.__ks_new_0([]), args);
			return color._dummy ? false : color.greyscale(model);
		}
		static greyscale() {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
			let pts;
			if(Helper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
				return Color.__ks_sttc_greyscale_0(Helper.getVarargs(arguments, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_hex_0(args) {
			const color = $from.__ks_0(Color.__ks_new_0([]), args);
			return color._dummy ? false : color.__ks_func_hex_0();
		}
		static hex() {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
			let pts;
			if(Helper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
				return Color.__ks_sttc_hex_0(Helper.getVarargs(arguments, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_negative_0(args) {
			const color = $from.__ks_0(Color.__ks_new_0([]), args);
			return color._dummy ? false : color.__ks_func_negative_0();
		}
		static negative() {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
			let pts;
			if(Helper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
				return Color.__ks_sttc_negative_0(Helper.getVarargs(arguments, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_registerFormatter_0(format, formatter) {
			$formatters[format] = (() => {
				const o = new OBJ();
				o.formatter = formatter;
				return o;
			})();
		}
		static registerFormatter() {
			const t0 = Type.isString;
			const t1 = Type.isFunction;
			if(arguments.length === 2) {
				if(t0(arguments[0]) && t1(arguments[1])) {
					return Color.__ks_sttc_registerFormatter_0(arguments[0], arguments[1]);
				}
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_registerParser_0(format, parser) {
			$parsers[format] = parser;
		}
		static registerParser() {
			const t0 = Type.isString;
			const t1 = Type.isFunction;
			if(arguments.length === 2) {
				if(t0(arguments[0]) && t1(arguments[1])) {
					return Color.__ks_sttc_registerParser_0(arguments[0], arguments[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
	Helper.implEnum(Space, "SRGB", "srgb", "RGB", "rgb");
	Color.__ks_sttc_addSpace_0((() => {
		const o = new OBJ();
		o["name"] = "srgb";
		o["alias"] = ["rgb"];
		o["formatters"] = (() => {
			const o = new OBJ();
			o.hex = Helper.function(function(that) {
				return $hex.__ks_0(that);
			}, (that, fn, ...args) => {
				const t0 = value => Type.isClassInstance(value, Color);
				if(args.length === 1) {
					if(t0(args[0])) {
						return fn.call(null, args[0]);
					}
				}
				throw Helper.badArgs();
			});
			o.srgb = Helper.function(function(that) {
				if(that._alpha === 1) {
					return "rgb(" + that._red + ", " + that._green + ", " + that._blue + ")";
				}
				else {
					return "rgba(" + that._red + ", " + that._green + ", " + that._blue + ", " + that._alpha + ")";
				}
			}, (that, fn, ...args) => {
				const t0 = value => Type.isClassInstance(value, Color);
				if(args.length === 1) {
					if(t0(args[0])) {
						return fn.call(null, args[0]);
					}
				}
				throw Helper.badArgs();
			});
			return o;
		})();
		o["components"] = (() => {
			const o = new OBJ();
			o["red"] = (() => {
				const o = new OBJ();
				o["max"] = 255;
				return o;
			})();
			o["green"] = (() => {
				const o = new OBJ();
				o["max"] = 255;
				return o;
			})();
			o["blue"] = (() => {
				const o = new OBJ();
				o["max"] = 255;
				return o;
			})();
			return o;
		})();
		return o;
	})());
	const $static = (() => {
		const o = new OBJ();
		o.black = Color.__ks_sttc_from_0(["#000"]);
		o.gray = Color.__ks_sttc_from_0(["#808080"]);
		o.white = Color.__ks_sttc_from_0(["#fff"]);
		return o;
	})();
	return {
		Color,
		Space
	};
};
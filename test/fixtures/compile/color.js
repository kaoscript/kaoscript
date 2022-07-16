require("kaoscript/register");
const {Dictionary, Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("./_/._array.ks.j5k8r9.ksb")().__ks_Array;
	var Float = require("./_/._float.ks.j5k8r9.ksb")().Float;
	var Integer = require("./_/._integer.ks.j5k8r9.ksb")().Integer;
	var __ks_Math = require("./_/._math.ks.j5k8r9.ksb")().__ks_Math;
	var __ks_Number = require("./_/._number.ks.j5k8r9.ksb")().__ks_Number;
	var __ks_String = require("./_/._string.ks.j5k8r9.ksb")().__ks_String;
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
		let that = first.call(null, ...firstArgs);
		let lastArgs = Helper.mapDictionary(components, function(name, component) {
			return that[component.field];
		});
		lastArgs.push(that);
		return last.call(null, ...lastArgs);
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
			const t0 = () => true;
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
				const d = new Dictionary();
				d.field = component.field;
				d.spaces = new Dictionary();
				d.families = [];
				return d;
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
				const d = new Dictionary();
				d._alpha = 0;
				return d;
			})();
		}
		let s;
		if(Type.isValue((s = $spaces[that._space]).converters[space])) {
			let args = Helper.mapDictionary(s.components, function(name, component) {
				return that[component.field];
			});
			args.push(result);
			s.converters[space](...args);
			result._space = Space.from(space);
			return result;
		}
		else {
			throw new Error("It can't convert a color from '" + that._space + "' to '" + space + "' spaces.");
		}
	};
	$convert.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Color);
		const t1 = Type.isString;
		const t2 = value => Type.isDictionary(value) || Type.isClassInstance(value, Color) || Type.isNull(value);
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
				$spaces[from].converters[to] = Helper.vcurry($binder, null, $spaces[name].converters[to], $spaces[name].components, $spaces[from].converters[name]);
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
			for(let name in $parsers) {
				let parse = $parsers[name];
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
	let $parsers = (() => {
		const d = new Dictionary();
		d.srgb = (() => {
			const __ks_rt = (...args) => {
				const t0 = value => Type.isClassInstance(value, Color);
				const t1 = Type.isArray;
				if(args.length === 2) {
					if(t0(args[0]) && t1(args[1])) {
						return __ks_rt.__ks_0.call(null, args[0], args[1]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = function(that, args) {
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
					else if(Type.isDictionary(args[0])) {
						if(Type.isValue(args[0].r) && Type.isValue(args[0].g) && Type.isValue(args[0].b)) {
							that._space = Space.SRGB;
							that._alpha = $caster.alpha.__ks_0(args[0].a);
							that._red = $caster.ff(args[0].r);
							that._green = $caster.ff(args[0].g);
							that._blue = $caster.ff(args[0].b);
							return true;
						}
						if(Type.isValue(args[0].red) && Type.isValue(args[0].green) && Type.isValue(args[0].blue)) {
							that._space = Space.SRGB;
							that._alpha = $caster.alpha.__ks_0(args[0].alpha);
							that._red = $caster.ff(args[0].red);
							that._green = $caster.ff(args[0].green);
							that._blue = $caster.ff(args[0].blue);
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
							that._red = Integer.parse.__ks_0(match[1], 16);
							that._green = Integer.parse.__ks_0(match[2], 16);
							that._blue = Integer.parse.__ks_0(match[3], 16);
							that._alpha = $caster.alpha.__ks_0(Integer.parse.__ks_0(match[4], 16) / 255);
							return true;
						}
						else if(Type.isValue(__ks_0 = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color)) ? (match = __ks_0, true) : false) {
							that._space = Space.SRGB;
							that._red = Integer.parse.__ks_0(match[1], 16);
							that._green = Integer.parse.__ks_0(match[2], 16);
							that._blue = Integer.parse.__ks_0(match[3], 16);
							that._alpha = 1;
							return true;
						}
						else if(Type.isValue(__ks_0 = /^#?([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)) ? (match = __ks_0, true) : false) {
							that._space = Space.SRGB;
							that._red = Integer.parse.__ks_0(Operator.addOrConcat(match[1], match[1]), 16);
							that._green = Integer.parse.__ks_0(Operator.addOrConcat(match[2], match[2]), 16);
							that._blue = Integer.parse.__ks_0(Operator.addOrConcat(match[3], match[3]), 16);
							that._alpha = $caster.alpha.__ks_0(Integer.parse.__ks_0(Operator.addOrConcat(match[4], match[4]), 16) / 255);
							return true;
						}
						else if(Type.isValue(__ks_0 = /^#?([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)) ? (match = __ks_0, true) : false) {
							that._space = Space.SRGB;
							that._red = Integer.parse.__ks_0(Operator.addOrConcat(match[1], match[1]), 16);
							that._green = Integer.parse.__ks_0(Operator.addOrConcat(match[2], match[2]), 16);
							that._blue = Integer.parse.__ks_0(Operator.addOrConcat(match[3], match[3]), 16);
							that._alpha = 1;
							return true;
						}
						else if(Type.isValue(__ks_0 = /^rgba?\((\d{1,3}),(\d{1,3}),(\d{1,3})(,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
							that._space = Space.SRGB;
							that._red = $caster.ff(match[1]);
							that._green = $caster.ff(match[2]);
							that._blue = $caster.ff(match[3]);
							that._alpha = $caster.alpha.__ks_0(match[5], Type.isValue(match[6]));
							return true;
						}
						else if(Type.isValue(__ks_0 = /^rgba?\(([0-9.]+\%),([0-9.]+\%),([0-9.]+\%)(,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
							that._space = Space.SRGB;
							that._red = Math.round(2.55 * $caster.percentage(match[1]));
							that._green = Math.round(2.55 * $caster.percentage(match[2]));
							that._blue = Math.round(2.55 * $caster.percentage(match[3]));
							that._alpha = $caster.alpha.__ks_0(match[5], Type.isValue(match[6]));
							return true;
						}
						else if(Type.isValue(__ks_0 = /^rgba?\(#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2}),([0-9.]+)(\%)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
							that._space = Space.SRGB;
							that._red = Integer.parse.__ks_0(match[1], 16);
							that._green = Integer.parse.__ks_0(match[2], 16);
							that._blue = Integer.parse.__ks_0(match[3], 16);
							that._alpha = $caster.alpha.__ks_0(match[4], Type.isValue(match[5]));
							return true;
						}
						else if(Type.isValue(__ks_0 = /^rgba\(#?([0-9a-f])([0-9a-f])([0-9a-f]),([0-9.]+)(\%)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
							that._space = Space.SRGB;
							that._red = Integer.parse.__ks_0(Operator.addOrConcat(match[1], match[1]), 16);
							that._green = Integer.parse.__ks_0(Operator.addOrConcat(match[2], match[2]), 16);
							that._blue = Integer.parse.__ks_0(Operator.addOrConcat(match[3], match[3]), 16);
							that._alpha = $caster.alpha.__ks_0(match[4], Type.isValue(match[5]));
							return true;
						}
						else if(Type.isValue(__ks_0 = /^(\d{1,3}),(\d{1,3}),(\d{1,3})(?:,([0-9.]+))?$/.exec(color)) ? (match = __ks_0, true) : false) {
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
			};
			return __ks_rt;
		})();
		d.gray = (() => {
			const __ks_rt = (...args) => {
				const t0 = value => Type.isClassInstance(value, Color);
				const t1 = Type.isArray;
				if(args.length === 2) {
					if(t0(args[0]) && t1(args[1])) {
						return __ks_rt.__ks_0.call(null, args[0], args[1]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = function(that, args) {
				if(args.length >= 1) {
					if(Number.isFinite(Float.parse.__ks_0(args[0])) === true) {
						that._space = Space.SRGB;
						that._red = that._green = that._blue = $caster.ff(args[0]);
						that._alpha = (args.length >= 2) ? $caster.alpha.__ks_0(args[1]) : 1;
						return true;
					}
					else if(Type.isString(args[0])) {
						let color = __ks_String.__ks_func_lower_0.call(args[0]).replace(/[^a-z0-9,.()#%]/g, "");
						let match, __ks_0;
						if(Type.isValue(__ks_0 = /^gray\((\d{1,3})(?:,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
							that._space = Space.SRGB;
							that._red = that._green = that._blue = $caster.ff(match[1]);
							that._alpha = $caster.alpha.__ks_0(match[2], Type.isValue(match[3]));
							return true;
						}
						else if(Type.isValue(__ks_0 = /^gray\(([0-9.]+\%)(?:,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
							that._space = Space.SRGB;
							that._red = that._green = that._blue = Math.round(2.55 * $caster.percentage(match[1]));
							that._alpha = $caster.alpha.__ks_0(match[2], Type.isValue(match[3]));
							return true;
						}
					}
				}
				return false;
			};
			return __ks_rt;
		})();
		return d;
	})();
	function $space() {
		return $space.__ks_rt(this, arguments);
	};
	$space.__ks_0 = function(name) {
		$spaces[name] = Type.isValue($spaces[name]) ? $spaces[name] : (() => {
			const d = new Dictionary();
			d.alias = new Dictionary();
			d.converters = new Dictionary();
			d.components = new Dictionary();
			return d;
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
	const Space = Helper.enum(String, {});
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
				let w = (percentage * 2) - 1;
				let a = color._alpha - this._alpha;
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
			let a = this._alpha;
			if(a === 1) {
				if(color._alpha !== 1) {
					color = color.__ks_func_clone_0().__ks_func_blend_0(this, 0.5, Space.SRGB, true);
				}
				let l1 = this.__ks_func_luminance_0() + 0.05;
				let l2 = color.__ks_func_luminance_0() + 0.05;
				let ratio = l1 / l2;
				if(l2 > l1) {
					ratio = 1 / ratio;
				}
				ratio = __ks_Number.__ks_func_round_0.call(ratio, 2);
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
				let black = this.__ks_func_clone_0().blend($static.black, 0.5, Space.SRGB, true).contrast(color).ratio;
				let white = this.__ks_func_clone_0().blend($static.white, 0.5, Space.SRGB, true).contrast(color).ratio;
				const max = Math.max(black, white);
				let closest = Color.__ks_new_0([__ks_Number.__ks_func_limit_0.call((color._red - (this._red * a)) / (1 - a), 0, 255), __ks_Number.__ks_func_limit_0.call((color._green - (this._green * a)) / (1 - a), 0, 255), __ks_Number.__ks_func_limit_0.call((color._blue - (this._blue * a)) / (1 - a), 0, 255)]);
				const min = this.__ks_func_clone_0().__ks_func_blend_0(closest, 0.5, Space.SRGB, true).__ks_func_contrast_0(color).ratio;
				return (() => {
					const d = new Dictionary();
					d.ratio = __ks_Number.__ks_func_round_0.call((min + max) / 2, 2);
					d.error = __ks_Number.__ks_func_round_0.call((max - min) / 2, 2);
					d.min = min;
					d.max = max;
					return d;
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
			let s1 = this._space;
			let s2 = target._space;
			this.__ks_func_space_1(Space.SRGB.value);
			target.__ks_func_space_1(Space.SRGB.value);
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
			const that = this.__ks_func_like_0(Space.SRGB.value);
			color = color.__ks_func_like_0(Space.SRGB.value);
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
				format = this._space;
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
			let gradient = [this];
			if(length > 0) {
				this.__ks_func_space_1(Space.SRGB.value);
				endColor.__ks_func_space_1(Space.SRGB.value);
				++length;
				let red = endColor._red - this._red;
				let green = endColor._green - this._green;
				let blue = endColor._blue - this._blue;
				for(let i = 1; i < length; ++i) {
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
			this.__ks_func_space_1(Space.SRGB.value);
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
			return $hex(this.__ks_func_like_0(Space.SRGB.value));
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
			let that = this.__ks_func_like_0(Space.SRGB.value);
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
				let that = this.__ks_func_like_0(Space.SRGB.value);
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
			let that = this.__ks_func_like_0(Space.SRGB.value);
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
			let value = Space.from(space);
			if(Type.isValue(value)) {
				if((this._space.value !== value.valueOf()) && Type.isValue($spaces[this._space].converters[space])) {
					return $convert(this, value);
				}
			}
			return this;
		}
		__ks_func_like_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_like_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		luminance() {
			return this.__ks_func_luminance_rt.call(null, this, this, arguments);
		}
		__ks_func_luminance_0() {
			const that = this.__ks_func_like_0(Space.SRGB.value);
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
			this.__ks_func_space_1(Space.SRGB.value);
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
			return Helper.mapArray(functions, (fn) => {
				return fn(this.__ks_func_clone_0());
			});
		}
		__ks_func_scheme_rt(that, proto, args) {
			const t0 = value => Type.isArray(value, Type.isFunction);
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
			space = Type.isValue($aliases[space]) ? $aliases[space] : space;
			if(!Type.isValue($spaces[space]) && Type.isValue($components[space])) {
				if(Type.isValue($spaces[this._space].components[space])) {
					return this;
				}
				else if($components[space].families.length === 1) {
					space = $components[space].families[0];
				}
				else {
					throw new Error(Helper.concatString("The component '", space, "' has a conflict between the spaces '", $components[space].families.join("', '"), "'"));
				}
			}
			let value = Space.from(space);
			if(Type.isValue(value)) {
				if((this._space.value !== value.valueOf()) && Type.isValue($spaces[this._space].converters[space])) {
					$convert(this, value, this);
				}
			}
			else {
				$convert.__ks_0(this, space, this);
			}
			return this;
		}
		__ks_func_space_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 0) {
				return proto.__ks_func_space_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_space_1.call(that, args[0]);
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
		static __ks_sttc_from_0(args) {
			let color = $from.__ks_0(Color.__ks_new_0([]), args);
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
			let color = $from.__ks_0(Color.__ks_new_0([]), args);
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
			let color = $from.__ks_0(Color.__ks_new_0([]), args);
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
			let color = $from.__ks_0(Color.__ks_new_0([]), args);
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
				const d = new Dictionary();
				d.formatter = formatter;
				return d;
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
		static __ks_sttc_registerSpace_0(space) {
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
					$aliases[alias] = Space.from(space.name);
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
							$space.__ks_0(name);
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
			const t0 = Type.isDictionary;
			if(arguments.length === 1) {
				if(t0(arguments[0])) {
					return Color.__ks_sttc_registerSpace_0(arguments[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	Space.SRGB = Space("srgb");
	Space.RGB = Space("rgb");
	Color.__ks_sttc_registerSpace_0((() => {
		const d = new Dictionary();
		d["name"] = "srgb";
		d["alias"] = ["rgb"];
		d["formatters"] = (() => {
			const d = new Dictionary();
			d.hex = (() => {
				const __ks_rt = (...args) => {
					const t0 = value => Type.isClassInstance(value, Color);
					if(args.length === 1) {
						if(t0(args[0])) {
							return __ks_rt.__ks_0.call(null, args[0]);
						}
					}
					throw Helper.badArgs();
				};
				__ks_rt.__ks_0 = function(that) {
					return $hex.__ks_0(that);
				};
				return __ks_rt;
			})();
			d.srgb = (() => {
				const __ks_rt = (...args) => {
					const t0 = value => Type.isClassInstance(value, Color);
					if(args.length === 1) {
						if(t0(args[0])) {
							return __ks_rt.__ks_0.call(null, args[0]);
						}
					}
					throw Helper.badArgs();
				};
				__ks_rt.__ks_0 = function(that) {
					if(that._alpha === 1) {
						return "rgb(" + that._red + ", " + that._green + ", " + that._blue + ")";
					}
					else {
						return "rgba(" + that._red + ", " + that._green + ", " + that._blue + ", " + that._alpha + ")";
					}
				};
				return __ks_rt;
			})();
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
		return this.__ks_func_getField_0("red");
	};
	Color.prototype.__ks_func_red_1 = function(value) {
		return this.setField("red", value);
	};
	Color.prototype.__ks_func_green_0 = function() {
		return this.__ks_func_getField_0("green");
	};
	Color.prototype.__ks_func_green_1 = function(value) {
		return this.setField("green", value);
	};
	Color.prototype.__ks_func_blue_0 = function() {
		return this.__ks_func_getField_0("blue");
	};
	Color.prototype.__ks_func_blue_1 = function(value) {
		return this.setField("blue", value);
	};
	Color.prototype.__ks_init_1 = Color.prototype.__ks_init;
	Color.prototype.__ks_init = function() {
		this.__ks_init_1();
		this._red = 0;
		this._green = 0;
		this._blue = 0;
	};
	Color.prototype.__ks_func_red_rt = function(that, proto, args) {
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
	};
	Color.prototype.red = function() {
		return this.__ks_func_red_rt.call(null, this, this, arguments);
	};
	Color.prototype.__ks_func_green_rt = function(that, proto, args) {
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
	};
	Color.prototype.green = function() {
		return this.__ks_func_green_rt.call(null, this, this, arguments);
	};
	Color.prototype.__ks_func_blue_rt = function(that, proto, args) {
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
	};
	Color.prototype.blue = function() {
		return this.__ks_func_blue_rt.call(null, this, this, arguments);
	};
	let $static = (() => {
		const d = new Dictionary();
		d.black = Color.__ks_sttc_from_0(["#000"]);
		d.gray = Color.__ks_sttc_from_0(["#808080"]);
		d.white = Color.__ks_sttc_from_0(["#fff"]);
		return d;
	})();
	return {
		Color,
		Space
	};
};
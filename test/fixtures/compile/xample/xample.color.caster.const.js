require("kaoscript/register");
var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Float = require("../_/_float.ks")().Float;
	var {Math, __ks_Math} = require("../_/_math.ks")();
	var {Number, __ks_Number} = require("../_/_number.ks")();
	const $caster = (() => {
		const d = new Dictionary();
		d.percentage = function(n) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(n === void 0 || n === null) {
				throw new TypeError("'n' is not nullable");
			}
			return __ks_Number._im_round(__ks_Number._im_limit(Float.parse(n), 0, 100), 1);
		};
		return d;
	})();
	function srgb(that, color) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(that === void 0 || that === null) {
			throw new TypeError("'that' is not nullable");
		}
		if(color === void 0 || color === null) {
			throw new TypeError("'color' is not nullable");
		}
		let match = /^rgba?\(([0-9.]+\%),([0-9.]+\%),([0-9.]+\%)(,([0-9.]+)(\%)?)?\)$/.exec(color);
		if(Type.isValue(match)) {
			that._red = Math.round(2.55 * $caster.percentage(match[1]));
			that._green = Math.round(2.55 * $caster.percentage(match[2]));
			that._blue = Math.round(2.55 * $caster.percentage(match[3]));
			return true;
		}
		else {
			return false;
		}
	}
};
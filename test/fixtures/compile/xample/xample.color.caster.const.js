require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Float = require("../_/._float.ks.j5k8r9.ksb")().Float;
	var __ks_Math = require("../_/._math.ks.j5k8r9.ksb")().__ks_Math;
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	const $caster = (() => {
		const d = new OBJ();
		d.percentage = Helper.function(function(n) {
			return __ks_Number.__ks_func_round_0.call(__ks_Number.__ks_func_limit_0.call(Float.parse.__ks_0(n), 0, 100), 1);
		}, (fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(null, args[0]);
				}
			}
			throw Helper.badArgs();
		});
		return d;
	})();
	function srgb() {
		return srgb.__ks_rt(this, arguments);
	};
	srgb.__ks_0 = function(that, color) {
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
	};
	srgb.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return srgb.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};
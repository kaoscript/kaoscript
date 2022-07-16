const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return x;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
		}
		__ks_cons_1(x, y) {
			if(x === void 0 || x === null) {
				x = "";
			}
			if(y === void 0 || y === null) {
				y = this.__ks_default_0_0(x);
			}
		}
		__ks_default_0_0(x) {
			return foobar.__ks_0(x);
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 0) {
				return Foobar.prototype.__ks_cons_0.call(that);
			}
			if(args.length >= 1 && args.length <= 2) {
				if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t0, pts = [1], 0) && te(pts, 1)) {
					return Foobar.prototype.__ks_cons_1.call(that, args[0], Helper.getVararg(args, 1, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
	}
	return {
		Foobar
	};
};
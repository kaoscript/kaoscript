const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
		__ks_cons_1(x) {
			if(x === void 0 || x === null) {
				x = "";
			}
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			if(args.length === 0) {
				return Foobar.prototype.__ks_cons_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return Foobar.prototype.__ks_cons_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Quxbaz extends Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(x) {
			if(x === void 0 || x === null) {
				x = "";
			}
			Foobar.prototype.__ks_cons_0.call(this);
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return Quxbaz.prototype.__ks_cons_0.call(that, Helper.getVararg(args, 0, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
	}
	return {
		Foobar,
		Quxbaz
	};
};
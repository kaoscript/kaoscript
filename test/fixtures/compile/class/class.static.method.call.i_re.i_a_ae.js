const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassA.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		static __ks_sttc_foobar_0(x, values) {
		}
		static foobar() {
			const t0 = Type.isNumber;
			const t1 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
			let pts;
			if(arguments.length >= 1) {
				if(t0(arguments[0]) && Helper.isVarargs(arguments, 0, arguments.length - 1, t1, pts = [1], 0) && te(pts, 1)) {
					return ClassA.__ks_sttc_foobar_0(arguments[0], Helper.getVarargs(arguments, 1, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z) {
		ClassA.__ks_sttc_foobar_0(x, [y, z]);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t1(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};
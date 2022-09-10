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
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(x) {
			if(x === void 0 || x === null) {
				x = "void";
			}
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return proto.__ks_func_foobar_0.call(that, Helper.getVararg(args, 0, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
	}
	class ClassB extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassB.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		__ks_func_foobar_1(x, y) {
			return this.__ks_func_foobar_0(x);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isString;
			const t1 = Type.isNumber;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return proto.__ks_func_foobar_1.call(that, args[0], args[1]);
				}
			}
			return super.__ks_func_foobar_rt.call(null, that, ClassA.prototype, args);
		}
	}
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ValueA {
		static __ks_new_0() {
			const o = Object.create(ValueA.prototype);
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
	}
	class ValueB extends ValueA {
		static __ks_new_0() {
			const o = Object.create(ValueB.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	ValueA.Foobar = ValueA.__ks_new_0();
	const EnumA = Helper.enum(Number, 0, "Foobar", 0);
	class MainA {
		static __ks_new_0() {
			const o = Object.create(MainA.prototype);
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
		prepare() {
			return this.__ks_func_prepare_rt.call(null, this, this, arguments);
		}
		__ks_func_prepare_0(value, mode) {
			if(value === void 0 || value === null) {
				value = ValueA.Foobar;
			}
			if(mode === void 0 || mode === null) {
				mode = EnumA.Foobar;
			}
		}
		__ks_func_prepare_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, ValueA) || Type.isNull(value);
			const t1 = value => Type.isEnumInstance(value, EnumA) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 2) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
					return proto.__ks_func_prepare_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		}
	}
	class MainB extends MainA {
		static __ks_new_0() {
			const o = Object.create(MainB.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		__ks_func_prepare_1(value, mode) {
			if(mode === void 0 || mode === null) {
				mode = EnumA.Foobar;
			}
		}
		__ks_func_prepare_0(value, mode) {
			if(value === void 0 || value === null) {
				value = ValueA.Foobar;
			}
			if(mode === void 0 || mode === null) {
				mode = EnumA.Foobar;
			}
		}
		__ks_func_prepare_rt(that, proto, args) {
			const t0 = value => Type.isEnumInstance(value, EnumA);
			const t1 = value => Type.isClassInstance(value, ValueB);
			const t2 = value => Type.isClassInstance(value, ValueA) || Type.isNull(value);
			const t3 = value => Type.isEnumInstance(value, EnumA) || Type.isNull(value);
			if(args.length === 0) {
				return proto.__ks_func_prepare_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_prepare_0.call(that, void 0, args[0]);
				}
				if(t1(args[0])) {
					return proto.__ks_func_prepare_1.call(that, args[0], void 0);
				}
				if(t2(args[0])) {
					return proto.__ks_func_prepare_0.call(that, args[0], void 0);
				}
			}
			if(args.length === 2) {
				if(t1(args[0])) {
					if(t3(args[1])) {
						return proto.__ks_func_prepare_1.call(that, args[0], args[1]);
					}
				}
				if(t2(args[0]) && t3(args[1])) {
					return proto.__ks_func_prepare_0.call(that, args[0], args[1]);
				}
			}
			return super.__ks_func_prepare_rt.call(null, that, MainA.prototype, args);
		}
	}
};
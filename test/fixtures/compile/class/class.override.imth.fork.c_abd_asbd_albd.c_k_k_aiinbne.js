const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
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
		__ks_func_foobar_0(value, flag) {
			if(flag === void 0 || flag === null) {
				flag = false;
			}
		}
		__ks_func_foobar_1(value, name, flag) {
			if(flag === void 0 || flag === null) {
				flag = false;
			}
		}
		__ks_func_foobar_2(value, data, flag) {
			if(flag === void 0 || flag === null) {
				flag = false;
			}
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isValue;
			const t1 = Type.isArray;
			const t2 = Type.isString;
			const t3 = value => Type.isBoolean(value) || Type.isNull(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0], void 0);
				}
				throw Helper.badArgs();
			}
			if(args.length === 2) {
				if(t0(args[0])) {
					if(t1(args[1])) {
						return proto.__ks_func_foobar_2.call(that, args[0], args[1], void 0);
					}
					if(t2(args[1])) {
						return proto.__ks_func_foobar_1.call(that, args[0], args[1], void 0);
					}
					if(t3(args[1])) {
						return proto.__ks_func_foobar_0.call(that, args[0], args[1]);
					}
					throw Helper.badArgs();
				}
				throw Helper.badArgs();
			}
			if(args.length === 3) {
				if(t0(args[0])) {
					if(t1(args[1])) {
						if(t3(args[2])) {
							return proto.__ks_func_foobar_2.call(that, args[0], args[1], args[2]);
						}
						throw Helper.badArgs();
					}
					if(t2(args[1]) && t3(args[2])) {
						return proto.__ks_func_foobar_1.call(that, args[0], args[1], args[2]);
					}
					throw Helper.badArgs();
				}
			}
			throw Helper.badArgs();
		}
	}
	class Quxbaz extends Foobar {
		static __ks_new_0() {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		__ks_func_foobar_0(value, flag) {
			if(flag === void 0 || flag === null) {
				flag = false;
			}
		}
		__ks_func_foobar_1(value, name, flag) {
			if(flag === void 0 || flag === null) {
				flag = false;
			}
		}
		__ks_func_foobar_3(value, from, to, flag) {
			if(to === void 0) {
				to = null;
			}
			if(flag === void 0) {
				flag = null;
			}
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isValue;
			const t1 = Type.isString;
			const t2 = value => Type.isBoolean(value) || Type.isNull(value);
			const t3 = Type.isNumber;
			const t4 = value => Type.isNumber(value) || Type.isNull(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0], void 0);
				}
			}
			if(args.length === 2) {
				if(t0(args[0])) {
					if(t1(args[1])) {
						return proto.__ks_func_foobar_1.call(that, args[0], args[1], void 0);
					}
					if(t2(args[1])) {
						return proto.__ks_func_foobar_0.call(that, args[0], args[1]);
					}
				}
			}
			if(args.length === 3) {
				if(t0(args[0]) && t1(args[1]) && t2(args[2])) {
					return proto.__ks_func_foobar_1.call(that, args[0], args[1], args[2]);
				}
			}
			if(args.length === 4) {
				if(t0(args[0]) && t3(args[1]) && t4(args[2]) && t2(args[3])) {
					return proto.__ks_func_foobar_3.call(that, args[0], args[1], args[2], args[3]);
				}
			}
			return super.__ks_func_foobar_rt.call(null, that, Foobar.prototype, args);
		}
	}
};
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
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x) {
		return x;
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
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
		__ks_func_foobar_0(x) {
		}
		__ks_func_foobar_1(x, y) {
			if(y === void 0 || y === null) {
				y = this.__ks_default_0_0(x);
			}
			return x;
		}
		__ks_default_0_0(x) {
			return foobar.__ks_0(x);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isBoolean;
			const t1 = Type.isString;
			const t2 = value => Type.isString(value) || Type.isNull(value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
				if(t1(args[0])) {
					return proto.__ks_func_foobar_1.call(that, args[0], void 0);
				}
				throw Helper.badArgs();
			}
			if(args.length === 2) {
				if(t1(args[0]) && t2(args[1])) {
					return proto.__ks_func_foobar_1.call(that, args[0], args[1]);
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
		__ks_func_foobar_1(x, y) {
			if(y === void 0 || y === null) {
				y = this.__ks_default_0_0(x);
			}
			return y;
		}
		__ks_func_foobar_2(x) {
			if(x === void 0 || x === null) {
				x = this.__ks_default_1_0();
			}
		}
		__ks_default_1_0() {
			return quxbaz.__ks_0(42);
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isString;
			const t1 = value => Type.isNumber(value) || Type.isNull(value);
			const t2 = value => Type.isString(value) || Type.isNull(value);
			if(args.length === 0) {
				return proto.__ks_func_foobar_2.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_1.call(that, args[0], void 0);
				}
				if(t1(args[0])) {
					return proto.__ks_func_foobar_2.call(that, args[0]);
				}
			}
			if(args.length === 2) {
				if(t0(args[0]) && t2(args[1])) {
					return proto.__ks_func_foobar_1.call(that, args[0], args[1]);
				}
			}
			return super.__ks_func_foobar_rt.call(null, that, Foobar.prototype, args);
		}
	}
	return {
		Foobar,
		Quxbaz
	};
};
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
		__ks_func_foobar_0(x) {
			return "quxbaz";
		}
		__ks_func_foobar_1(x) {
			return 42;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isNumber;
			const t1 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_1.call(that, args[0]);
				}
				if(t1(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0(a) {
			console.log(this.__ks_func_foobar_0("foo"));
			console.log(Helper.toString(this.__ks_func_foobar_1(0)));
			console.log(Helper.toString(this.foobar(a)));
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_quxbaz_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};
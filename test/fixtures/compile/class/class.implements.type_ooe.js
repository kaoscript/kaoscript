const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const TypeA = Helper.alias(value => Type.isDexObject(value, 1, 0, {foobar: Type.isFunction}));
	const TypeB = Helper.alias(value => Type.isDexObject(value, 1, 0, {quxbaz: Type.isFunction}));
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
		__ks_func_foobar_0() {
			return "";
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			throw Helper.badArgs();
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0() {
			return 0;
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_quxbaz_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};
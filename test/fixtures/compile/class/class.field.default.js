const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassA {
		static __ks_new_0(...args) {
			const o = Object.create(ClassA.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(x) {
			if(x === void 0) {
				x = null;
			}
			this._x = x;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return ClassA.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		foo() {
			return this.__ks_func_foo_rt.call(null, this, this, arguments);
		}
		__ks_func_foo_0() {
			this._x.foobar();
		}
		__ks_func_foo_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foo_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};
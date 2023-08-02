const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassA {
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
	class ClassB extends ClassA {
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	class ClassC extends ClassB {
		static __ks_new_0(...args) {
			const o = Object.create(ClassC.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(parent) {
			this._parent = parent;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isClassInstance(value, ClassB);
			if(args.length === 1) {
				if(t0(args[0])) {
					return ClassC.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		foobar() {
			return this._parent.__ks_func_foobar_rt.call(null, this._parent, this._parent, arguments);
		}
		__ks_func_foobar_0() {
			return this._parent.__ks_func_foobar_0(...arguments);
		}
		__ks_func_foobar_rt(that, proto, args) {
			return proto.foobar.apply(that, args);
		}
	}
};
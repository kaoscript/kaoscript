const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foo {
		static __ks_new_0(...args) {
			const o = Object.create(Foo.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(Foo.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		static __ks_new_2(...args) {
			const o = Object.create(Foo.prototype);
			o.__ks_init();
			o.__ks_cons_2(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(foo, bar) {
		}
		__ks_cons_1(foo, bar, qux) {
		}
		__ks_cons_2(foo, bar, qux) {
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			const t1 = Type.isString;
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return Foo.prototype.__ks_cons_0.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 3) {
				if(t0(args[0])) {
					if(t1(args[1])) {
						if(t0(args[2])) {
							return Foo.prototype.__ks_cons_1.call(that, args[0], args[1], args[2]);
						}
					}
					if(t0(args[1]) && t0(args[2])) {
						return Foo.prototype.__ks_cons_2.call(that, args[0], args[1], args[2]);
					}
					throw Helper.badArgs();
				}
			}
			throw Helper.badArgs();
		}
	}
};
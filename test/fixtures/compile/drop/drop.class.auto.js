const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Foo {
		static __ks_new_0() {
			const o = Object.create(Foo.prototype);
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
		static __ks_destroy_0(that) {
		}
		static __ks_destroy(that) {
			Foo.__ks_destroy_0(that);
		}
	}
	let foo = Foo.__ks_new_0();
	Foo.__ks_destroy(foo);
	foo = void 0;
};
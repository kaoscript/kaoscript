const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Foo {
		static __ks_new_0() {
			const o = Object.create(Foo.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
			this._bar = "";
		}
		__ks_cons_rt(that, args) {
			if(args.length === 0) {
				return Foo.prototype.__ks_cons_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};
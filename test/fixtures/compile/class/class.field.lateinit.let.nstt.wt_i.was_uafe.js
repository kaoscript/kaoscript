const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
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
			this.PI = 42;
			const x = this.PI + 3.14;
		}
		__ks_cons_rt(that, args) {
			if(args.length === 0) {
				return Foobar.prototype.__ks_cons_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};
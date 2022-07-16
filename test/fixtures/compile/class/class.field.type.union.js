const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassA.prototype);
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
			this._x = [];
		}
		__ks_cons_rt(that, args) {
			if(args.length === 0) {
				return ClassA.prototype.__ks_cons_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	return {
		ClassA
	};
};
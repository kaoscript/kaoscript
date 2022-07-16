const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassA {
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
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
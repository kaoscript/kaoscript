const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassB extends ClassA {
		constructor() {
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
	}
	class ClassC extends ClassB {
		constructor(x) {
			super();
			this._x = x;
		}
		__ks_init() {
			ClassB.prototype.__ks_init.call(this);
		}
		x() {
			return this.__ks_func_x_rt.call(null, this, this, arguments);
		}
		__ks_func_x_0() {
			return this._x;
		}
		__ks_func_x_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_x_0.call(that);
			}
			if(super.__ks_func_x_rt) {
				return super.__ks_func_x_rt.call(null, that, ClassB.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
};
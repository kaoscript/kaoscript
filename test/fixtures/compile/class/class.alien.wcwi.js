const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class ClassB extends ClassA {
		constructor(x, y) {
			super();
			this.constructor.prototype.__ks_init();
			this._x = x;
			this._y = y;
		}
		__ks_init_0() {
			this._x = 0;
			this._y = 0;
		}
		__ks_init() {
			ClassB.prototype.__ks_init_0.call(this);
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
				return super.__ks_func_x_rt.call(null, that, ClassA.prototype, args);
			}
			throw Helper.badArgs();
		}
		y() {
			return this.__ks_func_y_rt.call(null, this, this, arguments);
		}
		__ks_func_y_0() {
			return this._y;
		}
		__ks_func_y_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_y_0.call(that);
			}
			if(super.__ks_func_y_rt) {
				return super.__ks_func_y_rt.call(null, that, ClassA.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
	class ClassC extends ClassB {
		constructor() {
			super(...arguments);
		}
		__ks_init() {
			ClassB.prototype.__ks_init.call(this);
		}
	}
};
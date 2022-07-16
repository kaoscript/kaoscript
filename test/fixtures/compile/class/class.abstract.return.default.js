const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Shape {
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
	class Rectangle extends Shape {
		static __ks_new_0() {
			const o = Object.create(Rectangle.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		clone() {
			return this.__ks_func_clone_rt.call(null, this, this, arguments);
		}
		__ks_func_clone_0() {
			return this;
		}
		__ks_func_clone_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_clone_0.call(that);
			}
			if(super.__ks_func_clone_rt) {
				return super.__ks_func_clone_rt.call(null, that, Shape.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
};
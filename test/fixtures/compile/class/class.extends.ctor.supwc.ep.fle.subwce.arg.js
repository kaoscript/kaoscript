const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
			Shape.prototype.__ks_cons_1.call(this, "circle");
		}
		__ks_cons_1(name) {
			this._name = name;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 0) {
				return Shape.prototype.__ks_cons_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return Shape.prototype.__ks_cons_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Rectangle extends Shape {
		static __ks_new_0() {
			const o = Object.create(Rectangle.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		__ks_cons_0() {
			Shape.prototype.__ks_cons_1.call(this, "rectangle");
		}
		__ks_cons_rt(that, args) {
			if(args.length === 0) {
				return Rectangle.prototype.__ks_cons_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	class Foobar extends Shape {
		static __ks_new_0(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(color) {
			Shape.prototype.__ks_cons_0.call(this);
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Foobar.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};
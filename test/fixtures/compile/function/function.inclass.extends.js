const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		class Shape {
			static __ks_new_0(...args) {
				const o = Object.create(Shape.prototype);
				o.__ks_init();
				o.__ks_cons_0(...args);
				return o;
			}
			constructor() {
				this.__ks_init();
				this.__ks_cons_rt.call(null, this, arguments);
			}
			__ks_init() {
			}
			__ks_cons_0(color) {
				this._color = color;
			}
			__ks_cons_rt(that, args) {
				const t0 = Type.isString;
				if(args.length === 1) {
					if(t0(args[0])) {
						return Shape.prototype.__ks_cons_0.call(that, args[0]);
					}
				}
				throw Helper.badArgs();
			}
		}
		class Rectangle extends Shape {
			static __ks_new_0(...args) {
				const o = Object.create(Rectangle.prototype);
				o.__ks_init();
				o.__ks_cons_0(...args);
				return o;
			}
			__ks_cons_0(color) {
				Shape.prototype.__ks_cons_0.call(this, color);
			}
			__ks_cons_rt(that, args) {
				const t0 = Type.isString;
				if(args.length === 1) {
					if(t0(args[0])) {
						return Rectangle.prototype.__ks_cons_0.call(that, args[0]);
					}
				}
				throw Helper.badArgs();
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};
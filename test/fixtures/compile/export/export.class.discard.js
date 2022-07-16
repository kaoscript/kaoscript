const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Color {
		static __ks_new_0() {
			const o = Object.create(Color.prototype);
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
	}
	class Shape {
		static __ks_new_0() {
			const o = Object.create(Shape.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		static __ks_new_1(...args) {
			const o = Object.create(Shape.prototype);
			o.__ks_init();
			o.__ks_cons_1(...args);
			return o;
		}
		static __ks_new_2(...args) {
			const o = Object.create(Shape.prototype);
			o.__ks_init();
			o.__ks_cons_2(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
		}
		__ks_cons_1(name) {
			this._name = name;
		}
		__ks_cons_2(name, color) {
			this._name = name;
			this._color = color;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isString;
			const t1 = value => Type.isClassInstance(value, Color);
			if(args.length === 0) {
				return Shape.prototype.__ks_cons_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return Shape.prototype.__ks_cons_1.call(that, args[0]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 2) {
				if(t0(args[0]) && t1(args[1])) {
					return Shape.prototype.__ks_cons_2.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
		color() {
			return this.__ks_func_color_rt.call(null, this, this, arguments);
		}
		__ks_func_color_0() {
			return this._color;
		}
		__ks_func_color_1(color) {
			this._color = color;
			return this;
		}
		__ks_func_color_rt(that, proto, args) {
			const t0 = value => Type.isClassInstance(value, Color);
			if(args.length === 0) {
				return proto.__ks_func_color_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_color_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		name() {
			return this.__ks_func_name_rt.call(null, this, this, arguments);
		}
		__ks_func_name_0() {
			return this._name;
		}
		__ks_func_name_1(name) {
			this._name = name;
			return this;
		}
		__ks_func_name_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 0) {
				return proto.__ks_func_name_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_name_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	return {
		Shape
	};
};
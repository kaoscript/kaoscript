const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
			this._color = "";
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
		draw() {
			return this.__ks_func_draw_rt.call(null, this, this, arguments);
		}
		__ks_func_draw_0() {
			return "I'm drawing a " + this._color + " rectangle.";
		}
		__ks_func_draw_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_draw_0.call(that);
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_makeBlue_0() {
			return Shape.__ks_new_0("blue");
		}
		static makeBlue() {
			if(arguments.length === 0) {
				return Shape.__ks_sttc_makeBlue_0();
			}
			throw Helper.badArgs();
		}
	}
	Shape.prototype.__ks_func_name_0 = function() {
		return this._name;
	};
	Shape.prototype.__ks_func_name_1 = function(name) {
		this._name = name;
		return this;
	};
	Shape.prototype.__ks_func_draw_0 = function() {
		return "I'm drawing a " + this._color + " " + this._name + ".";
	};
	Shape.prototype.__ks_init_1 = Shape.prototype.__ks_init;
	Shape.prototype.__ks_init = function() {
		this.__ks_init_1();
		this._name = "circle";
	};
	Shape.prototype.__ks_func_name_rt = function(that, proto, args) {
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
	};
	Shape.prototype.name = function() {
		return this.__ks_func_name_rt.call(null, this, this, arguments);
	};
	let shape = Shape.__ks_sttc_makeBlue_0();
	console.log(shape.__ks_func_draw_0());
};
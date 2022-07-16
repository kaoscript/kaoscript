const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function defaultMessage() {
		return defaultMessage.__ks_rt(this, arguments);
	};
	defaultMessage.__ks_0 = function() {
		return "Hello!";
	};
	defaultMessage.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return defaultMessage.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	class Shape {
		static __ks_new_0() {
			const o = Object.create(Shape.prototype);
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
		draw() {
			return this.__ks_func_draw_rt.call(null, this, this, arguments);
		}
		__ks_func_draw_0(text) {
			if(text === void 0 || text === null) {
				text = this.__ks_default_0_0();
			}
			return text;
		}
		__ks_default_0_0() {
			return defaultMessage.__ks_0();
		}
		__ks_func_draw_rt(that, proto, args) {
			const t0 = value => Type.isString(value) || Type.isNull(value);
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length <= 1) {
				if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
					return proto.__ks_func_draw_0.call(that, Helper.getVararg(args, 0, pts[1]));
				}
			}
			throw Helper.badArgs();
		}
	}
	Shape.prototype.__ks_func_draw2_0 = function(text) {
		if(text === void 0 || text === null) {
			text = this.__ks_default_0_1();
		}
		return text + " I'm drawing a new shape.";
	};
	Shape.prototype.__ks_default_0_1 = function() {
		return defaultMessage.__ks_0();
	};
	Shape.prototype.__ks_func_draw2_rt = function(that, proto, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return proto.__ks_func_draw2_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	Shape.prototype.draw2 = function() {
		return this.__ks_func_draw2_rt.call(null, this, this, arguments);
	};
	return {
		Shape
	};
};
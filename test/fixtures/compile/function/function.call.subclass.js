const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Point2D {
		static __ks_new_0(...args) {
			const o = Object.create(Point2D.prototype);
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
		__ks_cons_0(x, y) {
			this._x = x;
			this._y = y;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isNumber;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return Point2D.prototype.__ks_cons_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
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
			throw Helper.badArgs();
		}
	}
	class Point3D extends Point2D {
		static __ks_new_0(...args) {
			const o = Object.create(Point3D.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(x, y, z) {
			Point2D.prototype.__ks_cons_0.call(this, x, y);
			this._z = z;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isNumber;
			if(args.length === 3) {
				if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
					return Point3D.prototype.__ks_cons_0.call(that, args[0], args[1], args[2]);
				}
			}
			throw Helper.badArgs();
		}
		z() {
			return this.__ks_func_z_rt.call(null, this, this, arguments);
		}
		__ks_func_z_0() {
			return this._z;
		}
		__ks_func_z_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_z_0.call(that);
			}
			if(super.__ks_func_z_rt) {
				return super.__ks_func_z_rt.call(null, that, Point2D.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
	function x() {
		return x.__ks_rt(this, arguments);
	};
	x.__ks_0 = function(point) {
		return point.__ks_func_x_0();
	};
	x.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Point2D);
		if(args.length === 1) {
			if(t0(args[0])) {
				return x.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const p = Point3D.__ks_new_0(1, 2, 3);
	console.log(x.__ks_0(p));
};
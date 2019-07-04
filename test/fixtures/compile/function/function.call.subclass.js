var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Point2D {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(x, y) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			else if(!Type.isNumber(y)) {
				throw new TypeError("'y' is not of type 'Number'");
			}
			this._x = x;
			this._y = y;
		}
		__ks_cons(args) {
			if(args.length === 2) {
				Point2D.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_x_0() {
			return this._x;
		}
		x() {
			if(arguments.length === 0) {
				return Point2D.prototype.__ks_func_x_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		__ks_func_y_0() {
			return this._y;
		}
		y() {
			if(arguments.length === 0) {
				return Point2D.prototype.__ks_func_y_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	class Point3D extends Point2D {
		__ks_init() {
			Point2D.prototype.__ks_init.call(this);
		}
		__ks_cons_0(x, y, z) {
			if(arguments.length < 3) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			else if(!Type.isNumber(y)) {
				throw new TypeError("'y' is not of type 'Number'");
			}
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
			else if(!Type.isNumber(z)) {
				throw new TypeError("'z' is not of type 'Number'");
			}
			Point2D.prototype.__ks_cons.call(this, [x, y]);
			this._z = z;
		}
		__ks_cons(args) {
			if(args.length === 3) {
				Point3D.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_z_0() {
			return this._z;
		}
		z() {
			if(arguments.length === 0) {
				return Point3D.prototype.__ks_func_z_0.apply(this);
			}
			else if(Point2D.prototype.z) {
				return Point2D.prototype.z.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	function x(point) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(point === void 0 || point === null) {
			throw new TypeError("'point' is not nullable");
		}
		else if(!Type.is(point, Point2D)) {
			throw new TypeError("'point' is not of type 'Point2D'");
		}
		return point.x();
	}
	const p = new Point3D(1, 2, 3);
	console.log(x(p));
};
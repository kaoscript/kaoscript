const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Point {
		static __ks_new_0(...args) {
			const o = Object.create(Point.prototype);
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
			this.x = x;
			this.y = y;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isNumber;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return Point.prototype.__ks_cons_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
	class Point3D extends Point {
		static __ks_new_0(...args) {
			const o = Object.create(Point3D.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(x, y, z) {
			Point.prototype.__ks_cons_0.call(this, x, y);
			this.z = z;
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
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(p) {
		const d3 = Helper.assert(p, "\"Point3D\"", 0, value => Type.isClassInstance(value, Point3D));
		console.log(d3.x + 1, d3.y + 2);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Point);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
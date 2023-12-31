const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Point = Helper.struct(function(x, y) {
		const _ = new OBJ();
		_.x = x;
		_.y = y;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Point)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isNumber(arg = item.x)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isNumber(arg = item.y)) {
			return null;
		}
		args[1] = arg;
		return __ks_new.call(null, args);
	});
	const Point3D = Helper.struct(function(x, y, z) {
		const _ = new OBJ();
		_.x = x;
		_.y = y;
		_.z = z;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return __ks_new(args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Point3D)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isNumber(arg = item.x)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isNumber(arg = item.y)) {
			return null;
		}
		args[1] = arg;
		if(!Type.isNumber(arg = item.z)) {
			return null;
		}
		args[2] = arg;
		return __ks_new.call(null, args);
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(p) {
		const d3 = Helper.assert(p, "\"Point\" or \"Point3D\"", 0, value => Type.isStructInstance(value, Point) || Type.isStructInstance(value, Point3D));
		console.log(d3.x + 1, d3.y + 2);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
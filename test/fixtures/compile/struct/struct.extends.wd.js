const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Point = Helper.struct(function(x, y) {
		if(x === void 0 || x === null) {
			x = 0;
		}
		if(y === void 0 || y === null) {
			y = 0;
		}
		const _ = new OBJ();
		_.x = x;
		_.y = y;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 2) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t0, pts, 1) && te(pts, 2)) {
				return __ks_new(Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	});
	const Point3D = Helper.struct(function(x, y, z) {
		const _ = Point.__ks_create(x, y);
		_.z = z;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const t1 = Type.isNumber;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 2) {
			if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
				return __ks_new(Helper.getVararg(args, 0, pts[1]), void 0, Helper.getVararg(args, pts[1], pts[2]));
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t1(args[2])) {
				return __ks_new(args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	});
	let point = Point3D.__ks_new(0.3, 0.4, 0.5);
	console.log(point.x + 1, point.y + 2, point.z + 3);
	return {
		Point,
		Point3D
	};
};
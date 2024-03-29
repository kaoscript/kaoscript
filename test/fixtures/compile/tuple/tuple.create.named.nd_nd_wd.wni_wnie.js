const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Point = Helper.tuple(function(x, y, z) {
		if(z === void 0 || z === null) {
			z = 0;
		}
		return [x, y, z];
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 2 && args.length <= 3) {
			if(t0(args[0]) && t0(args[1]) && Helper.isVarargs(args, 0, 1, t1, pts = [2], 0) && te(pts, 1)) {
				return __ks_new(args[0], args[1], Helper.getVararg(args, 2, pts[1]));
			}
		}
		throw Helper.badArgs();
	});
	const point = Point.__ks_new(0, 0);
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Point = Helper.tuple(function(x, y) {
		if(x === void 0 || x === null) {
			x = 0;
		}
		if(y === void 0 || y === null) {
			y = 0;
		}
		return [x, y];
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
	const point = Point.__ks_new();
};
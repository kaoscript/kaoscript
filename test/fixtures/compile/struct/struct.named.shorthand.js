const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(x, y, z) {
		if(x === void 0 || x === null) {
			x = 0;
		}
		if(y === void 0 || y === null) {
			y = 0;
		}
		if(z === void 0 || z === null) {
			z = 0;
		}
		const _ = new Dictionary();
		_.x = x;
		_.y = y;
		_.z = z;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 3) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t0, pts, 1) && Helper.isVarargs(args, 0, 1, t0, pts, 2) && te(pts, 3)) {
				return __ks_new(Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
			}
		}
		throw Helper.badArgs();
	});
	const y = -1;
	const a = Foobar.__ks_new(1, y);
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Pair = Helper.tuple(function(x, y) {
		if(x === void 0 || x === null) {
			x = "";
		}
		if(y === void 0 || y === null) {
			y = 0;
		}
		return [x, y];
	}, function(__ks_new, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		const t1 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 2) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
				return __ks_new(Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	});
	const Triple = Helper.tuple(function(x, y, z) {
		if(z === void 0 || z === null) {
			z = false;
		}
		const _ = Pair.__ks_builder(x, y);
		_.push(z);
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		const t1 = value => Type.isNumber(value) || Type.isNull(value);
		const t2 = value => Type.isBoolean(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 3) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && Helper.isVarargs(args, 0, 1, t2, pts, 2) && te(pts, 3)) {
				return __ks_new(Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
			}
		}
		throw Helper.badArgs();
	}, Pair);
	const triple = Triple.__ks_new("x", 0.1, true);
	console.log(triple[0], triple[1] + 1, !triple[2]);
	return {
		Pair,
		Triple
	};
};
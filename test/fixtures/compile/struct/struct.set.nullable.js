const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(qux = null) {
		const _ = new Dictionary();
		_.qux = qux;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isStructInstance(value, Quxbaz) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_new(Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	});
	const Quxbaz = Helper.struct(function(x, y) {
		const _ = new Dictionary();
		_.x = x;
		_.y = y;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	const point = Foobar.__ks_new();
	point.qux = Quxbaz.__ks_new(1, 1);
};
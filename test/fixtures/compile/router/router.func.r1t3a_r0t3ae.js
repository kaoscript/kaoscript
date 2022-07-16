const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(items, values) {
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 6) {
			if(Helper.isVarargs(args, 1, 3, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 3, t0, pts, 1) && te(pts, 2)) {
				return foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	};
};
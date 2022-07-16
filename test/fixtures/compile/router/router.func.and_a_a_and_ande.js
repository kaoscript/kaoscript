const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(u = null, v, x, y = null, z = null) {
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = () => true;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, void 0, args[0], args[1], void 0, void 0);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 3 && args.length <= 5) {
			if(t0(args[1]) && t0(args[2])) {
				if(Helper.isVarargs(args, 0, 1, t1, pts = [3], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
					return foobar.__ks_0.call(that, args[0], args[1], args[2], Helper.getVararg(args, 3, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
		}
		throw Helper.badArgs();
	};
};
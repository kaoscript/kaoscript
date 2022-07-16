const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const __ks_rt = (...args) => {
			const t0 = () => true;
			const t1 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 2) {
				if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
					return __ks_rt.__ks_0.call(this, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = (x = null, y) => {
			return [x, y];
		};
		return __ks_rt;
	})();
};
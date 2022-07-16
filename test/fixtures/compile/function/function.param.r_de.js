const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		const __ks_rt = (...args) => {
			const t0 = Type.isValue;
			const t1 = () => true;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
				return __ks_rt.__ks_0.call(null, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = function(items, x) {
			if(x === void 0 || x === null) {
				x = 42;
			}
			return [items, x];
		};
		return __ks_rt;
	})();
	expect(foo.__ks_0([])).to.eql([[], 42]);
	expect(foo.__ks_0([], 1)).to.eql([[], 1]);
	expect(foo.__ks_0([1], 2)).to.eql([[1], 2]);
	expect(foo.__ks_0([1, 2, 3], 4)).to.eql([[1, 2, 3], 4]);
};
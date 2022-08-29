const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		const __ks_rt = (...args) => {
			const t0 = () => true;
			const t1 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, args.length - 2, t1, pts, 1) && Helper.isVarargs(args, 0, 1, t0, pts, 2) && te(pts, 3)) {
				return __ks_rt.__ks_0.call(null, Helper.getVararg(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = function(x, items, y) {
			if(x === void 0 || x === null) {
				x = 24;
			}
			if(y === void 0 || y === null) {
				y = 42;
			}
			return [x, items, y];
		};
		return __ks_rt;
	})();
	expect(foo.__ks_0(void 0, [])).to.eql([24, [], 42]);
	expect(foo.__ks_0(1, [])).to.eql([1, [], 42]);
	expect(foo.__ks_0(1, [], 2)).to.eql([1, [], 2]);
	expect(foo.__ks_0(1, [2, 3], 4)).to.eql([1, [2, 3], 4]);
};
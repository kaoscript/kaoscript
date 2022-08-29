const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		const __ks_rt = (...args) => {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_rt.__ks_0.call(null, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = function(items) {
			return [items];
		};
		return __ks_rt;
	})();
	expect(foo.__ks_0([])).to.eql([[]]);
	expect(foo.__ks_0([1])).to.eql([[1]]);
	expect(foo.__ks_0([1, 2])).to.eql([[1, 2]]);
	expect(foo.__ks_0([1, 2, 3, 4])).to.eql([[1, 2, 3, 4]]);
};
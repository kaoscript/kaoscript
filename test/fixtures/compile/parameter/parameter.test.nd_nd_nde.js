const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = Helper.function(function(x = null, y = null, z = null) {
		return [x, y, z];
	}, (that, fn, ...args) => {
		const t0 = Type.any;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 3) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t0, pts, 1) && Helper.isVarargs(args, 0, 1, t0, pts, 2) && te(pts, 3)) {
				return fn.call(null, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
			}
		}
		throw Helper.badArgs();
	});
	expect(foo.__ks_0()).to.eql([null, null, null]);
	expect(foo.__ks_0(1)).to.eql([1, null, null]);
	expect(foo.__ks_0(1, 2)).to.eql([1, 2, null]);
	expect(foo.__ks_0(1, 2, 3)).to.eql([1, 2, 3]);
};
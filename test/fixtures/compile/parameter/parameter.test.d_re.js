const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = Helper.function(function(x, items) {
		if(x === void 0 || x === null) {
			x = 42;
		}
		return [x, items];
	}, (that, fn, ...args) => {
		const t0 = () => true;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, args.length, t1, pts, 1) && te(pts, 2)) {
			return fn.call(null, Helper.getVararg(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
		}
		throw Helper.badArgs();
	});
	expect(foo.__ks_0(42, [])).to.eql([42, []]);
	expect(foo.__ks_0(1, [])).to.eql([1, []]);
	expect(foo.__ks_0(1, [2])).to.eql([1, [2]]);
	expect(foo.__ks_0(1, [2, 3, 4])).to.eql([1, [2, 3, 4]]);
};
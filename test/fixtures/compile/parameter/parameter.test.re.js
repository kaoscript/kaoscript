const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = Helper.function(function(items) {
		return [items];
	}, (that, fn, ...args) => {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return fn.call(null, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	});
	expect(foo.__ks_0([])).to.eql([[]]);
	expect(foo.__ks_0([1])).to.eql([[1]]);
	expect(foo.__ks_0([1, 2])).to.eql([[1, 2]]);
	expect(foo.__ks_0([1, 2, 3, 4])).to.eql([[1, 2, 3, 4]]);
};
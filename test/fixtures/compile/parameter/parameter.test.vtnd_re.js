const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x = null, items) => {
			return [x, items];
		}, (fn, ...args) => {
			const t0 = value => Type.isNumber(value) || Type.isNull(value);
			const t1 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, args.length, t1, pts, 1) && te(pts, 2)) {
				return fn.call(this, Helper.getVararg(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
			}
			throw Helper.badArgs();
		});
	})();
	expect(foo()).to.eql([null, []]);
	expect(foo(1)).to.eql([1, []]);
	expect(foo("foo")).to.eql([null, ["foo"]]);
	expect(foo(1, 2)).to.eql([1, [2]]);
	expect(foo("foo", 1)).to.eql([null, ["foo", 1]]);
	expect(foo(null, "foo", 1)).to.eql([null, ["foo", 1]]);
};
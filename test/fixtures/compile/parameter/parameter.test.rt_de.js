const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((items, x) => {
			if(x === void 0 || x === null) {
				x = 42;
			}
			return [items, x];
		}, (that, fn, ...args) => {
			const t0 = Type.isString;
			const t1 = Type.any;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
				return fn.call(null, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
			throw Helper.badArgs();
		});
	})();
	expect(foo()).to.eql([[], 42]);
	expect(foo(1)).to.eql([[], 1]);
	expect(foo(true)).to.eql([[], true]);
	expect(foo(null)).to.eql([[], 42]);
	expect(foo("foo")).to.eql([[], "foo"]);
	expect(foo("foo", 2)).to.eql([["foo"], 2]);
	expect(foo("foo", true)).to.eql([["foo"], true]);
	expect(foo("foo", null)).to.eql([["foo"], 42]);
	expect(foo("foo", "bar", "qux")).to.eql([["foo", "bar"], "qux"]);
	expect(foo("foo", "bar", "qux", 4)).to.eql([["foo", "bar", "qux"], 4]);
};
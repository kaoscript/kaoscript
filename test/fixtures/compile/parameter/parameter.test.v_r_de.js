const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x, items, y) => {
			if(y === void 0 || y === null) {
				y = 42;
			}
			return [x, items, y];
		}, (that, fn, ...args) => {
			const t0 = Type.isValue;
			const t1 = () => true;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1) {
				if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 2, t0, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
					return fn.call(null, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
				}
			}
			throw Helper.badArgs();
		});
	})();
	expect(Helper.function(() => {
		return foo();
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo(1)).to.eql([1, [], 42]);
	expect(foo(1, 2)).to.eql([1, [], 2]);
	expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3], 4]);
};
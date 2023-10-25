const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((items, x, y) => {
			if(x === void 0 || x === null) {
				x = 42;
			}
			return [items, x, y];
		}, (that, fn, ...args) => {
			const t0 = Type.isValue;
			const t1 = Type.any;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(null, [], void 0, args[0]);
				}
				throw Helper.badArgs();
			}
			if(args.length >= 2) {
				if(Helper.isVarargs(args, 0, args.length - 2, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && Helper.isVarargs(args, 1, 1, t0, pts, 2) && te(pts, 3)) {
					return fn.call(null, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
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
	expect(foo(1)).to.eql([[], 42, 1]);
	expect(foo(1, 2)).to.eql([[], 1, 2]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2], 3, 4]);
};
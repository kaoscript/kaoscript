const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((items, values) => {
			return [items, values];
		}, (that, fn, ...args) => {
			const t0 = Type.isNumber;
			const t1 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(null, [], [args[0]]);
				}
				throw Helper.badArgs();
			}
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return fn.call(null, [], [args[0], args[1]]);
				}
				if(t1(args[0]) && t0(args[1])) {
					return fn.call(null, [args[0]], [args[1]]);
				}
				throw Helper.badArgs();
			}
			if(args.length >= 3) {
				if(Helper.isVarargs(args, 0, args.length - 3, t1, pts = [0], 0)) {
					if(Helper.isVarargs(args, 3, 3, t0, pts, 1) && te(pts, 2)) {
						return fn.call(null, Helper.getVarargs(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
					}
					if(Helper.isVarargs(args, 1, 1, t1, pts, 1)) {
						if(Helper.isVarargs(args, 2, 2, t0, pts, 2) && te(pts, 3)) {
							return fn.call(null, Helper.getVarargs(args, 0, pts[2]), Helper.getVarargs(args, pts[2], pts[3]));
						}
						if(Helper.isVarargs(args, 1, 1, t1, pts, 2) && Helper.isVarargs(args, 1, 1, t0, pts, 3) && te(pts, 4)) {
							return fn.call(null, Helper.getVarargs(args, 0, pts[3]), Helper.getVarargs(args, pts[3], pts[4]));
						}
						throw Helper.badArgs();
					}
					throw Helper.badArgs();
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
	expect(foo(1)).to.eql([[], [1]]);
	expect(foo(1, 2)).to.eql([[], [1, 2]]);
	expect(foo(1, 2, 3)).to.eql([[], [1, 2, 3]]);
	expect(foo(1, 2, 3, 4)).to.eql([[1], [2, 3, 4]]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([[1, 2], [3, 4, 5]]);
	expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], [4, 5, 6]]);
	expect(foo(1, 2, 3, 4, 5, 6, 7)).to.eql([[1, 2, 3, 4], [5, 6, 7]]);
};
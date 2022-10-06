const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((u = null, v = null, x, y = null, z = null) => {
			return [u, v, x, y, z];
		}, (fn, ...args) => {
			const t0 = () => true;
			const t1 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 2) {
				if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
					return fn.call(this, Helper.getVararg(args, 0, pts[1]), void 0, Helper.getVararg(args, pts[1], pts[2]), void 0, void 0);
				}
				throw Helper.badArgs();
			}
			if(args.length >= 3 && args.length <= 5) {
				if(t1(args[2])) {
					if(Helper.isVarargs(args, 0, 1, t0, pts = [3], 0) && Helper.isVarargs(args, 0, 1, t0, pts, 1) && te(pts, 2)) {
						return fn.call(this, args[0], args[1], args[2], Helper.getVararg(args, 3, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
					}
				}
			}
			throw Helper.badArgs();
		});
	})();
	expect(Helper.function(() => {
		return foo();
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo(1)).to.eql([null, null, 1, null, null]);
	expect(foo(1, 2)).to.eql([1, null, 2, null, null]);
	expect(foo(1, 2, 3)).to.eql([1, 2, 3, null, null]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5]);
};
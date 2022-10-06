const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((__ks_0, x) => {
			return [x];
		}, (fn, ...args) => {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1) {
				if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
					return fn.call(this, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
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
	expect(foo(1)).to.eql([1]);
	expect(foo(1, 2)).to.eql([2]);
	expect(foo(1, 2, 3, 4)).to.eql([4]);
};
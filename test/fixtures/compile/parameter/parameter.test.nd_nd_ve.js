const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x = null, y = null, z) => {
			return [x, y, z];
		}, (that, fn, ...args) => {
			const t0 = () => true;
			const t1 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 2) {
				if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
					return fn.call(null, Helper.getVararg(args, 0, pts[1]), void 0, Helper.getVararg(args, pts[1], pts[2]));
				}
				throw Helper.badArgs();
			}
			if(args.length === 3) {
				if(t1(args[2])) {
					return fn.call(null, args[0], args[1], args[2]);
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
	expect(foo(1)).to.eql([null, null, 1]);
	expect(foo(1, 2)).to.eql([1, null, 2]);
	expect(foo(1, 2, 3)).to.eql([1, 2, 3]);
};
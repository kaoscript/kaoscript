const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((items) => {
			return [items];
		}, (that, fn, ...args) => {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1) {
				if(Helper.isVarargs(args, 1, args.length, t0, pts = [0], 0) && te(pts, 1)) {
					return fn.call(null, Helper.getVarargs(args, 0, pts[1]));
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
	expect(foo(1)).to.eql([[1]]);
	expect(foo(1, 2)).to.eql([[1, 2]]);
	expect(foo(1, 2, 3)).to.eql([[1, 2, 3]]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3, 4]]);
};
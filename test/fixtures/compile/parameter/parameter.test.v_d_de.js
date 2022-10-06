const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x, y, z) => {
			if(y === void 0 || y === null) {
				y = 42;
			}
			if(z === void 0 || z === null) {
				z = 24;
			}
			return [x, y, z];
		}, (fn, ...args) => {
			const t0 = Type.isValue;
			const t1 = () => true;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(args.length >= 1 && args.length <= 3) {
				if(t0(args[0])) {
					if(Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
						return fn.call(this, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
					}
					throw Helper.badArgs();
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
	expect(foo(1)).to.eql([1, 42, 24]);
	expect(foo(1, 2)).to.eql([1, 2, 24]);
	expect(Helper.function(() => {
		return foo(1, 2, 3, 4);
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isValue;
				const t1 = () => true;
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length >= 1) {
					if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, args.length - 1, t0, pts, 1) && te(pts, 2)) {
						return __ks_rt.__ks_0.call(this, args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (x, y, items) => {
				if(y === void 0 || y === null) {
					y = 42;
				}
				return [x, y, items];
			};
			return __ks_rt;
		})();
	})();
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo();
		};
		return __ks_rt;
	})()).to.throw();
	expect(foo(1)).to.eql([1, 42, []]);
	expect(foo(1, 2)).to.eql([1, 2, []]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, [3, 4]]);
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = () => true;
				const t1 = Type.isValue;
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length >= 2 && args.length <= 3) {
					if(Helper.isVarargs(args, 0, args.length - 2, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && Helper.isVarargs(args, 1, 1, t1, pts, 2) && te(pts, 3)) {
						return __ks_rt.__ks_0.call(this, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), void 0, Helper.getVararg(args, pts[2], pts[3]), void 0);
					}
					throw Helper.badArgs();
				}
				if(args.length >= 4 && args.length <= 5) {
					if(t1(args[1]) && t1(args[3])) {
						return __ks_rt.__ks_0.call(this, args[0], args[1], args[2], args[3], args[4]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (u = null, v, x = null, y, z = null) => {
				return [u, v, x, y, z];
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
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo(1);
		};
		return __ks_rt;
	})()).to.throw();
	expect(foo(1, 2)).to.eql([null, 1, null, 2, null]);
	expect(foo(1, 2, 3)).to.eql([1, 2, null, 3, null]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5]);
};
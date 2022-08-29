const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isValue;
				const t1 = () => true;
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return __ks_rt.__ks_0.call(this, void 0, args[0], args[1], void 0, void 0);
					}
					throw Helper.badArgs();
				}
				if(args.length >= 3 && args.length <= 5) {
					if(t0(args[1]) && t0(args[2])) {
						if(Helper.isVarargs(args, 0, 1, t1, pts = [3], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
							return __ks_rt.__ks_0.call(this, args[0], args[1], args[2], Helper.getVararg(args, 3, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
						}
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (u = null, v, x, y = null, z = null) => {
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
	expect(foo(1, 2)).to.eql([null, 1, 2, null, null]);
	expect(foo(1, 2, 3)).to.eql([1, 2, 3, null, null]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5]);
};
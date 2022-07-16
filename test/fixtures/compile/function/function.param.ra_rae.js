const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isValue;
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length >= 2 && args.length <= 3) {
					if(Helper.isVarargs(args, 1, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
						return __ks_rt.__ks_0.call(this, Helper.getVarargs(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
					}
					throw Helper.badArgs();
				}
				if(args.length >= 4 && args.length <= 6) {
					if(t0(args[0]) && t0(args[1]) && t0(args[2]) && Helper.isVarargs(args, 1, 3, t0, pts = [3], 0) && te(pts, 1)) {
						return __ks_rt.__ks_0.call(this, [args[0], args[1], args[2]], Helper.getVarargs(args, 3, pts[1]));
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (items, values) => {
				return [items, values];
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
	expect(foo(1, 2)).to.eql([[1], [2]]);
	expect(foo(1, 2, 3)).to.eql([[1, 2], [3]]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], [4]]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([[1, 2, 3], [4, 5]]);
	expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], [4, 5, 6]]);
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo(1, 2, 3, 4, 5, 6, 7);
		};
		return __ks_rt;
	})()).to.throw();
};
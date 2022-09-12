const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = () => true;
				const t1 = Type.isValue;
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length >= 1 && args.length <= 2) {
					if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
						return __ks_rt.__ks_0.call(this, Helper.getVararg(args, 0, pts[1]), void 0, Helper.getVararg(args, pts[1], pts[2]));
					}
					throw Helper.badArgs();
				}
				if(args.length === 3) {
					if(t1(args[2])) {
						return __ks_rt.__ks_0.call(this, args[0], args[1], args[2]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (x = null, y = 42, z) => {
				return [x, y, z];
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
	expect(foo(1)).to.eql([null, 42, 1]);
	expect(foo(1, 2)).to.eql([1, 42, 2]);
	expect(foo(1, 2, 3)).to.eql([1, 2, 3]);
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = value => Type.isNumber(value) || Type.isNull(value);
				const t1 = Type.isString;
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length >= 1 && args.length <= 2) {
					if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
						return __ks_rt.__ks_0.call(this, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (x = null, y) => {
				return [x, y];
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
	expect(foo("foo")).to.eql([null, "foo"]);
	expect(foo(1, "foo")).to.eql([1, "foo"]);
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo", "bar");
		};
		return __ks_rt;
	})()).to.throw();
};
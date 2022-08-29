const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = value => Type.isNumber(value) || Type.isNull(value);
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length <= 1) {
					if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
						return __ks_rt.__ks_0.call(this, Helper.getVararg(args, 0, pts[1]));
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (x = null) => {
				return [x];
			};
			return __ks_rt;
		})();
	})();
	expect(foo()).to.eql([null]);
	expect(foo(1)).to.eql([1]);
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foo");
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
			return foo(1, 2);
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
			return foo("foo", 1);
		};
		return __ks_rt;
	})()).to.throw();
};
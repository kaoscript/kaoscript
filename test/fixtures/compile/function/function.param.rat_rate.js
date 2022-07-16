const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isNumber;
				const t1 = Type.isString;
				const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
				let pts;
				if(args.length >= 2 && args.length <= 6) {
					if(Helper.isVarargs(args, 1, 3, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 3, t1, pts, 1) && te(pts, 2)) {
						return __ks_rt.__ks_0.call(this, Helper.getVarargs(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]));
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
	expect(foo(1, "foo")).to.eql([[1], ["foo"]]);
	expect(foo(1, 2, 3, "foo")).to.eql([[1, 2, 3], ["foo"]]);
	expect(foo(1, "foo", "bar", "qux")).to.eql([[1], ["foo", "bar", "qux"]]);
	expect(foo(1, 2, 3, "foo", "bar", "qux")).to.eql([[1, 2, 3], ["foo", "bar", "qux"]]);
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo(1, 2, 3, 4, "foo");
		};
		return __ks_rt;
	})()).to.throw();
};
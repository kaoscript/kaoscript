const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = value => Type.isNumber(value) || Type.isNull(value);
				if(args.length === 1) {
					if(t0(args[0])) {
						return __ks_rt.__ks_0.call(this, args[0]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (x) => {
				if(x === void 0 || x === null) {
					x = 42;
				}
				return [x];
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
	expect(foo(null)).to.eql([42]);
	expect(foo(1)).to.eql([1]);
	expect((() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return foo("foobar");
		};
		return __ks_rt;
	})()).to.throw();
};
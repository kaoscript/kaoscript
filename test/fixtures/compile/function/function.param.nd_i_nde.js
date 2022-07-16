const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isValue;
				if(args.length === 1) {
					if(t0(args[0])) {
						return __ks_rt.__ks_0.call(this, void 0, args[0], void 0);
					}
					throw Helper.badArgs();
				}
				if(args.length >= 2 && args.length <= 3) {
					if(t0(args[1])) {
						return __ks_rt.__ks_0.call(this, args[0], args[1], args[2]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (x = null, __ks_0, z = null) => {
				return [x, z];
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
	expect(foo(1)).to.eql([null, null]);
	expect(foo(1, 2)).to.eql([1, null]);
	expect(foo(1, 2, 3)).to.eql([1, 3]);
};
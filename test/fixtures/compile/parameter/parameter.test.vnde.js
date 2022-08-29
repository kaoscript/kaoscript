const {Helper} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return (() => {
			const __ks_rt = (...args) => {
				if(args.length <= 1) {
					return __ks_rt.__ks_0.call(this, args[0]);
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
			return foo(1, 2);
		};
		return __ks_rt;
	})()).to.throw();
};
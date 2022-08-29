const {Helper} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		const __ks_rt = (...args) => {
			if(args.length <= 1) {
				return __ks_rt.__ks_0.call(null, args[0]);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = function(x) {
			if(x === void 0 || x === null) {
				x = 42;
			}
			return [x];
		};
		return __ks_rt;
	})();
	expect(foo.__ks_0()).to.eql([42]);
	expect(foo.__ks_0(1)).to.eql([1]);
};
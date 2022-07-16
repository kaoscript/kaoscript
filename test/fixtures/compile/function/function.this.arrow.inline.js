const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return (() => {
			const __ks_rt = (...args) => {
				if(args.length === 0) {
					return __ks_rt.__ks_0.call(this);
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = () => {
				return this;
			};
			return __ks_rt;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};
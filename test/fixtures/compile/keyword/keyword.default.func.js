const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function __ks_default_1() {
		return __ks_default_1.__ks_rt(this, arguments);
	};
	__ks_default_1.__ks_0 = function() {
		console.log("hello");
	};
	__ks_default_1.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_default_1.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_default_1.__ks_0();
};
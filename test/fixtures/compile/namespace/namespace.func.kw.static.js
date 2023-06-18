const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let Float = Helper.namespace(function() {
		function __ks_static_1() {
			return __ks_static_1.__ks_rt(this, arguments);
		};
		__ks_static_1.__ks_0 = function() {
		};
		__ks_static_1.__ks_rt = function(that, args) {
			if(args.length === 0) {
				return __ks_static_1.__ks_0.call(that);
			}
			throw Helper.badArgs();
		};
		return {
			static: __ks_static_1
		};
	});
	return {
		Float
	};
};
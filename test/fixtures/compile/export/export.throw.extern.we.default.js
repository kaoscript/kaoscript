const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_SyntaxError = {};
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	return {
		foo,
		__ks_SyntaxError
	};
};
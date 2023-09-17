const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		if(x === void 0) {
			x = null;
		}
		x = 42;
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foo.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function toString() {
		return toString.__ks_rt(this, arguments);
	};
	toString.__ks_0 = function() {
		console.log("hello");
	};
	toString.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return toString.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};
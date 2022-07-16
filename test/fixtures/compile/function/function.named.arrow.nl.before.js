const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function hello() {
		return hello.__ks_rt(this, arguments);
	};
	hello.__ks_0 = function() {
		return "Hello :)";
	};
	hello.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return hello.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};
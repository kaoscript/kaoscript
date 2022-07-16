const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function isNotString() {
		return isNotString.__ks_rt(this, arguments);
	};
	isNotString.__ks_0 = function(value = null) {
		return !Type.isString(value);
	};
	isNotString.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return isNotString.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};
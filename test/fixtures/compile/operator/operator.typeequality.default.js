const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function isString() {
		return isString.__ks_rt(this, arguments);
	};
	isString.__ks_0 = function(value = null) {
		return Type.isString(value);
	};
	isString.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return isString.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};
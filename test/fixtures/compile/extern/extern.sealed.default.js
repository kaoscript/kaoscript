const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Number = {};
	__ks_Number.__ks_func_zeroPad_0 = function() {
		return "00" + this.toString();
	};
	__ks_Number._im_zeroPad = function(that, ...args) {
		return __ks_Number.__ks_func_zeroPad_rt(that, args);
	};
	__ks_Number.__ks_func_zeroPad_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Number.__ks_func_zeroPad_0.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_Number.__ks_func_zeroPad_0.call(Math.pow(3, 2));
	__ks_Number.__ks_func_zeroPad_0.call(Math.PI);
};
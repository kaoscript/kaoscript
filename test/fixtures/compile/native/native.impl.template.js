const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_String = {};
	__ks_String.__ks_func_toInt_0 = function(base) {
		if(base === void 0 || base === null) {
			base = 10;
		}
		return Helper.assertNumber(parseInt(this, base), 0);
	};
	__ks_String._im_toInt = function(that, ...args) {
		return __ks_String.__ks_func_toInt_rt(that, args);
	};
	__ks_String.__ks_func_toInt_rt = function(that, args) {
		if(args.length <= 1) {
			return __ks_String.__ks_func_toInt_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	let d = 4;
	let u = 2;
	console.log(__ks_String.__ks_func_toInt_0.call(Helper.concatString(d, u)));
};
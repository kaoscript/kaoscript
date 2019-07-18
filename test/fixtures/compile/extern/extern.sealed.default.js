module.exports = function() {
	var __ks_Number = {};
	__ks_Number.__ks_func_zeroPad_0 = function() {
		return "00" + this.toString();
	};
	__ks_Number._im_zeroPad = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Number.__ks_func_zeroPad_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	var __ks_Math = {};
	__ks_Number._im_zeroPad(Math.pow(3, 2));
	__ks_Number._im_zeroPad(Math.PI);
};
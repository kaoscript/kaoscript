var Dictionary = require("@kaoscript/runtime").Dictionary;
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
	let Math = (() => {
		const d = new Dictionary();
		d.PI = 3.14;
		return d;
	})();
	__ks_Number._im_zeroPad(Math.PI);
};
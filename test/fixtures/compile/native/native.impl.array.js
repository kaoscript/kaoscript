var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_func_last_0 = function(index) {
		if(index === void 0 || index === null) {
			index = 1;
		}
		else if(!Type.isNumber(index)) {
			throw new TypeError("'index' is not of type 'Number'");
		}
		return (this.length !== 0) ? this[this.length - index] : null;
	};
	__ks_Array._im_last = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_Array.__ks_func_last_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	console.log(__ks_Array._im_last([1, 2, 3]));
};
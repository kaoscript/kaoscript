module.exports = function() {
	var __ks_Array = {};
	__ks_Array.__ks_func_last_0 = function(index) {
		if(index === void 0 || index === null) {
			index = 1;
		}
		return this.length ? this[this.length - index] : null;
	};
	__ks_Array._im_last = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_Array.__ks_func_last_0.apply(that, args);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	console.log(__ks_Array._im_last([1, 2, 3]));
};
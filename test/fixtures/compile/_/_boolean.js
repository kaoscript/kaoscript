module.exports = function() {
	var __ks_Boolean = {};
	__ks_Boolean.__ks_func_toInt_0 = function() {
		return this ? 1 : 0;
	};
	__ks_Boolean._im_toInt = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Boolean.__ks_func_toInt_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		__ks_Boolean: __ks_Boolean
	};
};
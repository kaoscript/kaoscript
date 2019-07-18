module.exports = function() {
	var __ks_Number = {};
	__ks_Number.__ks_func_mod_0 = function(max) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(max === void 0 || max === null) {
			throw new TypeError("'max' is not nullable");
		}
		if(isNaN(this)) {
			return 0;
		}
		else {
			let n = this % max;
			if(n < 0) {
				return n + max;
			}
			else {
				return n;
			}
		}
	};
	__ks_Number._im_mod = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 1) {
			return __ks_Number.__ks_func_mod_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	console.log(__ks_Number._im_mod(42, 3));
};
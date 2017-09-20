module.exports = function() {
	var __ks_Boolean = {};
	var __ks_String = {};
	__ks_Boolean.__ks_func_toBoolean_0 = function() {
		return this;
	};
	__ks_Boolean._im_toBoolean = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Boolean.__ks_func_toBoolean_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	__ks_String.__ks_func_toBoolean_0 = function() {
		return /^(?:true|1|on|yes)$/i.test(this);
	};
	__ks_String._im_toBoolean = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_toBoolean_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	console.log(__ks_Boolean._im_toBoolean(true));
	console.log(__ks_String._im_toBoolean("true"));
};
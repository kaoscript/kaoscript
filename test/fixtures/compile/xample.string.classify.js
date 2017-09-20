module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_capitalizeWords_0 = function() {
		return this;
	};
	__ks_String._im_capitalizeWords = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_capitalizeWords_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	__ks_String.__ks_func_classify_0 = function() {
		return __ks_String._im_capitalizeWords(this.replace(/[-_]/g, " ").replace(/([A-Z])/g, " $1")).replace(/\s/g, "");
	};
	__ks_String._im_classify = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_classify_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
};
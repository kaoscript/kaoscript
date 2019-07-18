var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_capitalize_0 = function() {
		return this;
	};
	__ks_String.__ks_func_capitalizeWords_0 = function() {
		return Helper.mapArray(this.split(" "), function(item) {
			return __ks_String._im_capitalize(item);
		}).join(" ");
	};
	__ks_String._im_capitalize = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_capitalize_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_String._im_capitalizeWords = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_capitalizeWords_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};
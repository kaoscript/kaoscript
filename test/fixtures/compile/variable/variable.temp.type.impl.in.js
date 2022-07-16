const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_capitalize_0 = function() {
		return this;
	};
	__ks_String.__ks_func_capitalizeWords_0 = function() {
		return Helper.mapArray(this.split(" "), function(item) {
			return __ks_String.__ks_func_capitalize_0.call(item);
		}).join(" ");
	};
	__ks_String._im_capitalize = function(that, ...args) {
		return __ks_String.__ks_func_capitalize_rt(that, args);
	};
	__ks_String.__ks_func_capitalize_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_capitalize_0.call(that);
		}
		throw Helper.badArgs();
	};
	__ks_String._im_capitalizeWords = function(that, ...args) {
		return __ks_String.__ks_func_capitalizeWords_rt(that, args);
	};
	__ks_String.__ks_func_capitalizeWords_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_capitalizeWords_0.call(that);
		}
		throw Helper.badArgs();
	};
};
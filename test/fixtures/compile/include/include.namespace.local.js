const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let NS = Helper.namespace(function() {
		const __ks_String = {};
		__ks_String.__ks_func_lines_0 = function(emptyLines) {
			if(emptyLines === void 0 || emptyLines === null) {
				emptyLines = false;
			}
			if(this.length === 0) {
				return [];
			}
			else if(emptyLines === true) {
				return this.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n");
			}
			else {
				let __ks_0;
				return Type.isValue(__ks_0 = this.match(/[^\r\n]+/g)) ? __ks_0 : [];
			}
		};
		__ks_String.__ks_func_lower_0 = function() {
			return this.toLowerCase();
		};
		__ks_String.__ks_func_toFloat_0 = function() {
			return parseFloat(this);
		};
		__ks_String.__ks_func_toInt_0 = function(base) {
			if(base === void 0 || base === null) {
				base = 10;
			}
			return parseInt(this, base);
		};
		__ks_String._im_lines = function(that, ...args) {
			return __ks_String.__ks_func_lines_rt(that, args);
		};
		__ks_String.__ks_func_lines_rt = function(that, args) {
			if(args.length <= 1) {
				return __ks_String.__ks_func_lines_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		};
		__ks_String._im_lower = function(that, ...args) {
			return __ks_String.__ks_func_lower_rt(that, args);
		};
		__ks_String.__ks_func_lower_rt = function(that, args) {
			if(args.length === 0) {
				return __ks_String.__ks_func_lower_0.call(that);
			}
			throw Helper.badArgs();
		};
		__ks_String._im_toFloat = function(that, ...args) {
			return __ks_String.__ks_func_toFloat_rt(that, args);
		};
		__ks_String.__ks_func_toFloat_rt = function(that, args) {
			if(args.length === 0) {
				return __ks_String.__ks_func_toFloat_0.call(that);
			}
			throw Helper.badArgs();
		};
		__ks_String._im_toInt = function(that, ...args) {
			return __ks_String.__ks_func_toInt_rt(that, args);
		};
		__ks_String.__ks_func_toInt_rt = function(that, args) {
			if(args.length <= 1) {
				return __ks_String.__ks_func_toInt_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		};
		return {
			__ks_String
		};
	});
};
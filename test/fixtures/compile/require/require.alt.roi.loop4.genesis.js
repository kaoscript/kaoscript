var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Array, __ks_String) {
	if(!Type.isValue(__ks_Array)) {
		__ks_Array = {};
	}
	if(!Type.isValue(__ks_String)) {
		__ks_String = {};
	}
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
	__ks_String.__ks_func_lines_0 = function(emptyLines) {
		if(emptyLines === void 0 || emptyLines === null) {
			emptyLines = false;
		}
		else if(!Type.isBoolean(emptyLines)) {
			throw new TypeError("'emptyLines' is not of type 'Boolean'");
		}
		if(this.length === 0) {
			return [];
		}
		else if(emptyLines) {
			return this.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n");
		}
		else {
			let __ks_0;
			return Type.isValue(__ks_0 = this.match(/[^\r\n]+/g)) ? __ks_0 : [];
		}
	};
	__ks_String._im_lines = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length >= 0 && args.length <= 1) {
			return __ks_String.__ks_func_lines_0.apply(that, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		__ks_Array: __ks_Array,
		__ks_String: __ks_String
	};
};
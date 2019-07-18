var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length >= 2 && Type.isArray(arguments[arguments.length - 1])) {
			let __ks_i = -1;
			let begin = arguments[++__ks_i];
			if(begin === void 0 || begin === null) {
				throw new TypeError("'begin' is not nullable");
			}
			let args = arguments.length > __ks_i + 2 ? Array.prototype.slice.call(arguments, __ks_i + 1, arguments.length - 1) : [];
			__ks_i += args.length;
			let end = arguments[__ks_i];
			if(end === void 0 || end === null) {
				throw new TypeError("'end' is not nullable");
			}
			else if(!Type.isArray(end)) {
				throw new TypeError("'end' is not of type 'Array'");
			}
			console.log("Array");
		}
		else if(arguments.length >= 2 && Type.isString(arguments[arguments.length - 1])) {
			let __ks_i = -1;
			let begin = arguments[++__ks_i];
			if(begin === void 0 || begin === null) {
				throw new TypeError("'begin' is not nullable");
			}
			let args = arguments.length > __ks_i + 2 ? Array.prototype.slice.call(arguments, __ks_i + 1, arguments.length - 1) : [];
			__ks_i += args.length;
			let end = arguments[__ks_i];
			if(end === void 0 || end === null) {
				throw new TypeError("'end' is not nullable");
			}
			else if(!Type.isString(end)) {
				throw new TypeError("'end' is not of type 'String'");
			}
			console.log("String");
		}
		else if(arguments.length >= 2) {
			let __ks_i = -1;
			let begin = arguments[++__ks_i];
			if(begin === void 0 || begin === null) {
				throw new TypeError("'begin' is not nullable");
			}
			let args = arguments.length > __ks_i + 2 ? Array.prototype.slice.call(arguments, __ks_i + 1, arguments.length - 1) : [];
			__ks_i += args.length;
			let end = arguments[__ks_i];
			if(end === void 0 || end === null) {
				throw new TypeError("'end' is not nullable");
			}
			console.log("Any");
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	return {
		foobar: foobar
	};
};
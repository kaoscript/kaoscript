var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length >= 1) {
			if(Type.isArray(arguments[0])) {
				let __ks_i = -1;
				let value = arguments[++__ks_i];
				if(value === void 0 || value === null) {
					throw new TypeError("'value' is not nullable");
				}
				else if(!Type.isArray(value)) {
					throw new TypeError("'value' is not of type 'Array'");
				}
				let args = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : [];
				console.log("Array");
				return;
			}
			else if(Type.isString(arguments[0])) {
				let __ks_i = -1;
				let value = arguments[++__ks_i];
				if(value === void 0 || value === null) {
					throw new TypeError("'value' is not nullable");
				}
				else if(!Type.isString(value)) {
					throw new TypeError("'value' is not of type 'String'");
				}
				let args = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : [];
				console.log("String");
				return;
			}
		}
		let __ks_i = -1;
		let value = arguments[++__ks_i];
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		let args = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : [];
		console.log("Any");
	};
	return {
		foobar: foobar
	};
};
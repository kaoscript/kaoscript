var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Array = {};
	function reverse() {
		if(arguments.length === 1) {
			if(Type.isString(arguments[0])) {
				let __ks_i = -1;
				let value = arguments[++__ks_i];
				if(value === void 0 || value === null) {
					throw new TypeError("'value' is not nullable");
				}
				else if(!Type.isString(value)) {
					throw new TypeError("'value' is not of type 'String'");
				}
				return value.split("").reverse().join("");
			}
			else {
				let __ks_i = -1;
				let value = arguments[++__ks_i];
				if(value === void 0 || value === null) {
					throw new TypeError("'value' is not nullable");
				}
				else if(!Type.isArray(value)) {
					throw new TypeError("'value' is not of type 'Array'");
				}
				return value.slice().reverse();
			}
		}
		else {
			throw new SyntaxError("wrong number of arguments");
		}
	};
	const foo = reverse([1, 2, 3]);
	console.log(foo.toString());
};
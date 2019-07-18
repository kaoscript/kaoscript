var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let Util = (function() {
		function reverse() {
			if(arguments.length === 1 && Type.isString(arguments[0])) {
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
			else if(arguments.length === 1) {
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
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		};
		return {
			reverse: reverse
		};
	})();
	const foo = Util.reverse("hello");
	console.log(foo);
};
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo() {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		let __ks_i = -1;
		let data = arguments[++__ks_i];
		if(data === void 0 || data === null) {
			throw new TypeError("'data' is not nullable");
		}
		let __ks_0 = arguments[++__ks_i];
		if(__ks_0 !== null && !Type.isObject(__ks_0)) {
			throw new TypeError("anonymous argument is not of type 'Object'");
		}
		let name;
		if(arguments.length > 2 && (name = arguments[++__ks_i]) !== void 0 && name !== null) {
			if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
		}
		else {
			name = data.name;
		}
		console.log(name);
	}
};
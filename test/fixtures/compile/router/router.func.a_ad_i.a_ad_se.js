var {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		if((arguments.length === 2 && Type.isNumber(arguments[1])) || (arguments.length === 3 && Type.isNumber(arguments[2]))) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let __ks__;
			let y = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 0;
			let z = arguments[++__ks_i];
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
			else if(!Type.isNumber(z)) {
				throw new TypeError("'z' is not of type 'Number'");
			}
			return x.times(Operator.addOrConcat(y, z));
		}
		else if(arguments.length === 2 || arguments.length === 3) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let __ks__;
			let y = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 0;
			let z = arguments[++__ks_i];
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
			else if(!Type.isString(z)) {
				throw new TypeError("'z' is not of type 'String'");
			}
			return Helper.concatString(x.times(y), z);
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};
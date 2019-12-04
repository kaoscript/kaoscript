module.exports = function() {
	function foobar() {
		if(arguments.length === 1) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
		}
		else if(arguments.length === 2 || arguments.length === 3) {
			let __ks_i = -1;
			let a = arguments[++__ks_i];
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
			let b = arguments[++__ks_i];
			if(b === void 0 || b === null) {
				throw new TypeError("'b' is not nullable");
			}
			let __ks__;
			let c = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 1;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};
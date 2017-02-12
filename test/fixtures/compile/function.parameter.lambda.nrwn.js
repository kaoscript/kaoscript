module.exports = function() {
	let foo = function() {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		let __ks_i = -1;
		let __ks__;
		let x = arguments.length > 1 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
		let y = arguments[++__ks_i];
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		return [x, y];
	};
}
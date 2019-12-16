module.exports = function() {
	function foobar() {
		if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			return 1;
		}
		else {
			let values = Array.prototype.slice.call(arguments, 0, arguments.length);
			return 2;
		}
	};
	foobar(1, 2);
};
module.exports = function() {
	let foo = function(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0) {
			x = null;
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		return [x, y];
	};
};
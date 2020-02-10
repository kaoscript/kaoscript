var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Color = Helper.enum(Number, {
		Red: 0,
		Green: 1,
		Blue: 2
	});
	function foobar(color) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(color === void 0 || color === null) {
			throw new TypeError("'color' is not nullable");
		}
		else if(!Type.isEnumInstance(color, Color)) {
			throw new TypeError("'color' is not of type 'Color'");
		}
		if(color.value === 42) {
		}
	}
};
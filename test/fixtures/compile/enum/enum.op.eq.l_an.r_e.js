var Helper = require("@kaoscript/runtime").Helper;
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
		if(color === void 0) {
			color = null;
		}
		if(Helper.valueOf(color) === Color.Red.value) {
		}
	}
};
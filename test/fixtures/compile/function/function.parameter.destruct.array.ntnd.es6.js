var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function foobar([x, y]) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		console.log(Helper.concatString(x, ".", y));
	}
};
var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = Helper.struct(function(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		const _ = new Dictionary();
		_.x = x;
		return _;
	});
	const f = Foobar("");
	f.x = null;
};
var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = Helper.struct(function(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0) {
			x = null;
		}
		else if(x !== null && !Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String?'");
		}
		const _ = new Dictionary();
		_.x = x;
		return _;
	});
	const f = Foobar("");
	f.x = null;
};
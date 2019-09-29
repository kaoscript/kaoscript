var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Color = Helper.enum(Number, {
		Red: 0,
		Green: 1,
		Blue: 2
	});
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0) {
			x = null;
		}
		else if(x !== null && !Type.isEnumMember(x, Color)) {
			throw new TypeError("'x' is not of type 'Color?'");
		}
		if(x.value === null) {
		}
		while(quxbaz().value !== null) {
		}
	}
	function quxbaz() {
		return null;
	}
};
var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const map = (() => {
		const d = new Dictionary();
		d.pi = 3.14;
		return d;
	})();
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isNumber(x)) {
			throw new TypeError("'x' is not of type 'Number'");
		}
	}
	foobar(map.pi + 1);
};
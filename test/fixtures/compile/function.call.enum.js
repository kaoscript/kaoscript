var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let Foobar = {
		X: 0,
		Y: 1,
		Z: 2
	};
	function toString(foo) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(foo === void 0 || foo === null) {
			throw new TypeError("'foo' is not nullable");
		}
		else if(!Type.is(foo, Foobar)) {
			throw new TypeError("'foo' is not of type 'Foobar'");
		}
		return "xyz";
	}
	console.log(toString(Foobar.X));
};
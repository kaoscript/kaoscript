var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Foobar = Helper.enum(Number, {
		X: 0,
		Y: 1,
		Z: 2
	});
	function toString(foo) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(foo === void 0 || foo === null) {
			throw new TypeError("'foo' is not nullable");
		}
		else if(!Type.isEnumInstance(foo, Foobar)) {
			throw new TypeError("'foo' is not of type 'Foobar'");
		}
		return "xyz";
	}
	console.log(toString(Foobar.X));
};
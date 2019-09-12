var {Helper, Operator} = require("@kaoscript/runtime");
module.exports = function() {
	let o = {
		name: "White"
	};
	function fff(prefix) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(prefix === void 0 || prefix === null) {
			throw new TypeError("'prefix' is not nullable");
		}
		return Operator.addOrConcat(prefix, this.name);
	}
	let f = Helper.vcurry(fff, o);
	let s = f("Hello ");
};
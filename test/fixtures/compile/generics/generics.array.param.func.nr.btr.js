var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(functions) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(functions === void 0 || functions === null) {
			throw new TypeError("'functions' is not nullable");
		}
		else if(!Type.isArray(functions, Function)) {
			throw new TypeError("'functions' is not of type 'Array<(x: String)>'");
		}
		return Helper.mapArray(functions, function(fn) {
			return fn("foobar");
		});
	}
};
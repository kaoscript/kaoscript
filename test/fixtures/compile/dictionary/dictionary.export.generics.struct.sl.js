var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = Helper.struct(function(item) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(item === void 0 || item === null) {
			throw new TypeError("'item' is not nullable");
		}
		else if(!Type.isDictionary(item) || !Type.isArray(item.values)) {
			throw new TypeError("'item' is not of type '{values: Array<String>?}'");
		}
		const _ = new Dictionary();
		_.item = item;
		return _;
	});
	return {
		Foobar: Foobar
	};
};
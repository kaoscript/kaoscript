var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = Helper.struct(function(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		else if(!Type.isDictionary(values, String)) {
			throw new TypeError("'values' is not of type 'Dictionary<String>'");
		}
		const _ = new Dictionary();
		_.values = values;
		return _;
	});
	var Quxbaz = Helper.struct(function(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		else if(!Type.isDictionary(values, Number)) {
			throw new TypeError("'values' is not of type 'Dictionary<Number>'");
		}
		const _ = new Dictionary();
		_.values = values;
		return _;
	});
	function foobar(item) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(item === void 0 || item === null) {
			throw new TypeError("'item' is not nullable");
		}
		else if(!(Type.isStructInstance(item, Foobar) || Type.isStructInstance(item, Quxbaz))) {
			throw new TypeError("'item' is not of type 'Foobar' or 'Quxbaz'");
		}
		for(let __ks_0 in item.values) {
			const value = item.values[__ks_0];
		}
	}
};
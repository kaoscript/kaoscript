var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Event = Helper.struct(function(ok, value) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(ok === void 0 || ok === null) {
			throw new TypeError("'ok' is not nullable");
		}
		else if(!Type.isBoolean(ok)) {
			throw new TypeError("'ok' is not of type 'Boolean'");
		}
		if(value === void 0 || value === null) {
			throw new TypeError("'value' is not nullable");
		}
		const _ = new Dictionary();
		_.ok = ok;
		_.value = value;
		return _;
	});
	function foobar() {
		let value;
		if((value = quxbaz()).ok === true) {
		}
	}
	function quxbaz() {
	}
};
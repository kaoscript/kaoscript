require("kaoscript/register");
var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {String, __ks_String} = require("../_/_string.ks")();
	const $formatters = new Dictionary();
	function format(format) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(format === void 0 || format === null) {
			throw new TypeError("'format' is not nullable");
		}
		else if(!Type.isString(format)) {
			throw new TypeError("'format' is not of type 'String'");
		}
		let __ks_format_1 = $formatters[format];
		if(Type.isValue(__ks_format_1)) {
			return __ks_format_1.formatter(__ks_format_1.space);
		}
		else {
			return false;
		}
	}
};
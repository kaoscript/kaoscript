var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Float = Helper.namespace(function() {
		function parse(value = null) {
			return parseFloat(value);
		}
		return {
			parse: parse
		};
	});
	return {
		Float: Float
	};
};
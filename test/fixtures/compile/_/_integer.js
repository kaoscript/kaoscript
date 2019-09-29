var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Integer = Helper.namespace(function() {
		function parse(value = null, radix = null) {
			return parseInt(value, radix);
		}
		return {
			parse: parse
		};
	});
	return {
		Integer: Integer
	};
};
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let NS = Helper.namespace(function() {
		function foo() {
			return "42";
		}
		return {};
	});
	return {
		NS: NS
	};
};
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let NS = Helper.namespace(function() {
		return {};
	});
	function foo() {
		return "42";
	}
	function qux() {
		return "42";
	}
	return {
		NS: NS
	};
};
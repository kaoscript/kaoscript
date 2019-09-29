var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let NS = Helper.namespace(function() {
		let MD = Helper.namespace(function() {
			function foo() {
				return "42";
			}
			return {};
		});
		function foo() {
			return "42";
		}
		return {
			MD: MD
		};
	});
	function foo() {
		return "42";
	}
	return {
		NS: NS
	};
};
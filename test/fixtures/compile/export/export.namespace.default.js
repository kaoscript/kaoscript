var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let NS = Helper.namespace(function() {
		function foo() {
		}
		function bar() {
		}
		function qux() {
		}
		return {
			foo: foo,
			bar: bar,
			qux: qux
		};
	});
	return {
		NS: NS
	};
};
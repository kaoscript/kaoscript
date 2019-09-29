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
		nsFoo: NS.foo,
		nsBar: NS.bar,
		nsQux: NS.qux
	};
};
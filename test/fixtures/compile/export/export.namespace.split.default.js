var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let NS = Helper.namespace(function() {
		function foo() {
			return "foo";
		}
		function bar() {
			return "bar";
		}
		function qux() {
			return "aux";
		}
		return {
			foo: foo,
			bar: bar,
			qux: qux
		};
	});
	return {
		NS: NS,
		foobar: NS.foo
	};
};
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let NS = Helper.namespace(function() {
		function foo() {
		}
		function bar() {
		}
		function qux() {
		}
		let Type = Helper.enum(Number, {
			FOO: 0,
			BAR: 1,
			QUX: 2
		});
		return {
			foo: foo,
			bar: bar,
			qux: qux,
			Type: Type
		};
	});
	return {
		NS: NS
	};
};
module.exports = function() {
	let NS = (function() {
		function foo() {
		}
		function bar() {
		}
		function qux() {
		}
		let Type = {
			FOO: 0,
			BAR: 1,
			QUX: 2
		};
		return {
			foo: foo,
			bar: bar,
			qux: qux,
			Type: Type
		};
	})();
	return {
		NS: NS
	};
};
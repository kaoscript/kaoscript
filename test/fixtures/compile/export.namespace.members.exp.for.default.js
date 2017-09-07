module.exports = function() {
	let NS = (function() {
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
	})();
	return {
		foo: NS.foo,
		bar: NS.bar,
		qux: NS.qux
	};
}
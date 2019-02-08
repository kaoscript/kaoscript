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
		NS: NS,
		foobar: NS.foo
	};
};
module.exports = function() {
	let NS = (function() {
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
	})();
	return {
		NS: NS,
		foobar: NS.foo
	};
};
module.exports = function() {
	let NS = (function() {
		function foo() {
		}
		return {
			foo: foo
		};
	})();
	return {
		nsFoo: NS.foo
	};
};
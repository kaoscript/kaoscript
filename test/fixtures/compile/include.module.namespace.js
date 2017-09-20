module.exports = function() {
	let ns = (function() {
		function foo() {
		}
		const bar = 42;
		return {
			foo: foo,
			bar: bar
		};
	})();
	const foo = ns.bar;
	console.log(ns.foo());
};
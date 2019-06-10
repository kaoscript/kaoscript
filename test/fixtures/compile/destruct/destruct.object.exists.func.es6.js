module.exports = function() {
	function foo() {
		return {
			bar: "hello",
			baz: 3
		};
	}
	let bar = 0;
	let baz;
	({bar, baz} = foo());
	console.log(bar);
	console.log(baz);
};
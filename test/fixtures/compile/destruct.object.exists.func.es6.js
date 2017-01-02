module.exports = function() {
	function foo() {
		return {
			bar: "hello",
			baz: 3
		};
	}
	let bar = 0;
	var {bar: __ks_0, baz} = foo();
	bar = __ks_0;
	console.log(bar);
	console.log(baz);
}
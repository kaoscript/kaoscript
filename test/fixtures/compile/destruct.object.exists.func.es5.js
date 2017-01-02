module.exports = function() {
	function foo() {
		return {
			bar: "hello",
			baz: 3
		};
	}
	let bar = 0;
	let __ks_0;
	var bar = (__ks_0 = foo()).bar, baz = __ks_0.baz;
	console.log(bar);
	console.log(baz);
}
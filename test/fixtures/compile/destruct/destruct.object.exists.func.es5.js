module.exports = function() {
	function foo() {
		return {
			bar: "hello",
			baz: 3
		};
	}
	let bar = 0;
	let baz, __ks_0;
	bar = (__ks_0 = foo()).bar, baz = __ks_0.baz;
	console.log(bar);
	console.log(baz);
};
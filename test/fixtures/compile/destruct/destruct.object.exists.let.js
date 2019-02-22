module.exports = function() {
	const foo = {
		bar: "hello",
		baz: 3
	};
	let bar = "foo";
	var {bar: __ks_0, baz} = foo;
	bar = __ks_0;
	console.log(bar, baz);
};
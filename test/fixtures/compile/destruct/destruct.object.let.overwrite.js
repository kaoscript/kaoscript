module.exports = function() {
	const foo = {
		bar: "hello",
		baz: 3
	};
	let {bar, baz} = foo;
	bar = "foo";
	console.log(bar, baz);
};
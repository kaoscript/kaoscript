module.exports = function() {
	const foo = {
		bar: "hello",
		baz: 3
	};
	var {bar, baz} = foo;
	console.log(bar, baz);
};
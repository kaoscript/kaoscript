module.exports = function() {
	const foo = {
		bar: "hello",
		baz: 3
	};
	const {bar, baz} = foo;
	console.log(bar, baz);
};
module.exports = function() {
	let foo = {
		bar: "hello",
		baz: 3
	};
	let {bar, baz} = foo;
	console.log(bar);
	console.log(baz);
};
module.exports = function() {
	const arr = [1, "", true];
	let a = "foo";
	let c = "bar";
	let b;
	[a, b, c] = arr;
	console.log(a, b, c);
};
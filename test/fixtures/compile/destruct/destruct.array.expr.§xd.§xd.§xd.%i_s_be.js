module.exports = function() {
	const arr = [1, "", true];
	let a = "foo";
	let b;
	let c = "bar";
	([a, b, c] = arr);
	console.log(a, b, c);
};
module.exports = function() {
	const arr = [1, "", true];
	let a = "foo";
	let b, c;
	([a, b, c] = arr);
	console.log(a, b, c);
};
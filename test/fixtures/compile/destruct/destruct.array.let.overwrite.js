module.exports = function() {
	const arr = [1, "", true];
	let [a, b, c] = arr;
	a = "foo";
	console.log(a, b, c);
};
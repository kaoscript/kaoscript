module.exports = function() {
	const arr = [1, "", true];
	const [a, b, c] = arr;
	console.log(a + 1, b, !c);
};
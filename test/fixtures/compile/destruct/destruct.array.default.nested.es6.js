module.exports = function() {
	let arr = [[1, "", true], [1, "", true]];
	var [[a, b, c], [d, e, f]] = arr;
	console.log(a, b, c, d, e, f);
};
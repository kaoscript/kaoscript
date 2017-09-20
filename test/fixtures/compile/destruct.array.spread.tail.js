module.exports = function() {
	var [x, y, ...remaining] = [1, 2, 3, 4];
	console.log(x, y, remaining);
};
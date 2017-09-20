module.exports = function() {
	function foo() {
		return [1, 2];
	}
	var [x, y] = foo();
	console.log(x, y);
};
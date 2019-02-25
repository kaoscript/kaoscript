module.exports = function() {
	function foo() {
		return [1, 2];
	}
	const [x, y] = foo();
	console.log(x, y);
};
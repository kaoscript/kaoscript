module.exports = function() {
	function foo() {
		return [1, 2];
	}
	let [x, y] = foo();
	console.log(x, y);
};
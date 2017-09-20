module.exports = function() {
	function foo(x, y = 1, ...args) {
		console.log(x, y, args);
	}
};
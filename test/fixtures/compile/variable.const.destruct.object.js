module.exports = function() {
	function foo() {
		return {
			x: 1,
			y: 2
		};
	}
	var {x, y} = foo();
	console.log(x, y);
}
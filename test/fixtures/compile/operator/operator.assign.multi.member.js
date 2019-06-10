module.exports = function() {
	function foobar() {
		return 42;
	}
	let x, y;
	x = y.x = foobar();
};
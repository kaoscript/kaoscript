module.exports = function() {
	function foobar() {
		return 42;
	}
	let x;
	let y = {};
	x = y.x = foobar();
};
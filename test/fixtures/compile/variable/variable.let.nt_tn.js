module.exports = function() {
	function foobar() {
		return null;
	}
	let x = foobar();
	x = foobar();
	return {
		x: x
	};
};
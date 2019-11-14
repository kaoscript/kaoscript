module.exports = function() {
	function foobar() {
		return null;
	}
	let x = foobar();
	return {
		x: x
	};
};
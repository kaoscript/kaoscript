module.exports = function() {
	function foobar(x) {
	}
	foobar((function() {
		return "foobar";
	})());
};
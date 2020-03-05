module.exports = function() {
	function foobar(x) {
	}
	foobar((() => {
		return "foobar";
	})());
};
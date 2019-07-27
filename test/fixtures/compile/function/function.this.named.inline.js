module.exports = function() {
	function foobar() {
		function fn() {
			return this;
		}
		return fn;
	}
};
module.exports = function() {
	function $noop() {
		return "";
	}
	function foo() {
		return $noop;
	}
};
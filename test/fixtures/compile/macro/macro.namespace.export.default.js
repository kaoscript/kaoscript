module.exports = function() {
	let NS = (function() {
		return {};
	})();
	function foo() {
		return "42";
	}
	return {
		NS: NS
	};
};
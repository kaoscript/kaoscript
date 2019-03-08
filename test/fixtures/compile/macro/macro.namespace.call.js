module.exports = function() {
	let NS = (function() {
		function foo() {
			return "42";
		}
		return {};
	})();
	return {
		NS: NS
	};
};
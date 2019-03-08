module.exports = function() {
	let NS = (function() {
		let MD = (function() {
			function foo() {
				return "42";
			}
			return {};
		})();
		function foo() {
			return "42";
		}
		return {
			MD: MD
		};
	})();
	function foo() {
		return "42";
	}
	function bar() {
		return "42";
	}
	return {
		NS: NS
	};
};
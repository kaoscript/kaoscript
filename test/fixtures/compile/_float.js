module.exports = function() {
	let Float = (function() {
		function parse(value = null) {
			return parseFloat(value);
		}
		return {
			parse: parse
		};
	})();
	return {
		Float: Float
	};
}
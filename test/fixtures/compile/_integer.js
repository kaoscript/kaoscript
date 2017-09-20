module.exports = function() {
	let Integer = (function() {
		function parse(value = null, radix = null) {
			return parseInt(value, radix);
		}
		return {
			parse: parse
		};
	})();
	return {
		Integer: Integer
	};
};
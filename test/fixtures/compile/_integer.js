module.exports = function() {
	let Integer = {
		parse(value = null, radix = null) {
			return parseInt(value, radix);
		}
	};
	return {
		Integer: Integer
	};
}
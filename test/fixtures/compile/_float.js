module.exports = function() {
	let Float = {
		parse(value = null) {
			return parseFloat(value);
		}
	};
	return {
		Float: Float
	};
}
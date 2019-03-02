module.exports = function() {
	var __ks_SyntaxError = {};
	const foobar = {
		corge() {
			throw new SyntaxError();
		}
	};
};
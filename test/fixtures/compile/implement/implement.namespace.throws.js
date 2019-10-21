module.exports = function() {
	NS.foobar = function() {
		throw new Error();
	};
	return {
		NS: NS
	};
};
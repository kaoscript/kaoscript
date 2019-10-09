module.exports = function() {
	function foobar() {
		throw new Error();
	}
	return {
		foobar: foobar
	};
};
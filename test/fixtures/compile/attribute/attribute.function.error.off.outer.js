module.exports = function() {
	function error() {
		throw new Error();
	}
	function foobar() {
		error();
	}
};
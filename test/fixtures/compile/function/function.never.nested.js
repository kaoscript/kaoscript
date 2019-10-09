module.exports = function() {
	function foobar() {
		quxbaz();
	}
	function quxbaz() {
		throw new Error();
	}
};
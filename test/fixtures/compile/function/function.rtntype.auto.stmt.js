module.exports = function() {
	function foobar() {
		return "foobar";
	}
	console.log(foobar());
	return {
		foobar: foobar
	};
};
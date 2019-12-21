module.exports = function() {
	function foobar() {
		let z = null;
		z = 0;
		for(let i = 1; i <= 10; ++i) {
			z = i;
		}
		return z;
	}
};
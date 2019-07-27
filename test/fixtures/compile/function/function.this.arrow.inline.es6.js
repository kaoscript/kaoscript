module.exports = function() {
	function foobar() {
		return () => {
			return this;
		};
	}
};
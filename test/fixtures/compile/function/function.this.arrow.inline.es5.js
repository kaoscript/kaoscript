module.exports = function() {
	function foobar() {
		return (function() {
			return this;
		}).bind(this);
	}
};
module.exports = function() {
	function foobar([x, y] = ["foo", "bar"]) {
		console.log(x + "." + y);
	}
};
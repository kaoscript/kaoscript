module.exports = function() {
	function foobar({x, y} = {
		x: "foo",
		y: "bar"
	}) {
		console.log(x + "." + y);
	}
};
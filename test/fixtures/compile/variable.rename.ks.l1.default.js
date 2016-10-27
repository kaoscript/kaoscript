module.exports = function() {
	function foobar(x) {
		if(x === undefined || x === null) {
			x = "jane";
		}
		if(true) {
			let x = "john";
			console.log(x);
		}
	}
}
module.exports = function() {
	function foobar(x) {
		if(x === void 0 || x === null) {
			x = "jane";
		}
		if(true) {
			let x = "john";
			console.log(x);
		}
	}
};
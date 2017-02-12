module.exports = function() {
	function foobar(x) {
		if(x === void 0 || x === null) {
			x = "jane";
		}
		if(true) {
			var __ks_x_1 = "john";
			console.log(__ks_x_1);
		}
	}
}
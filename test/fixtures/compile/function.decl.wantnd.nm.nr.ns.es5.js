module.exports = function() {
	function foo(bar, qux) {
		if(bar === void 0) {
			bar = null;
		}
		if(qux === void 0) {
			qux = null;
		}
	}
};
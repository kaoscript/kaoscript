module.exports = function() {
	function foo(bar, qux) {
		if(bar === undefined) {
			bar = null;
		}
		if(qux === undefined) {
			qux = null;
		}
	}
}
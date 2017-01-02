module.exports = function() {
	function foo(__ks_static_1) {
		if(__ks_static_1 === undefined || __ks_static_1 === null) {
			throw new Error("Missing parameter 'static'");
		}
		console.log(__ks_static_1);
	}
}
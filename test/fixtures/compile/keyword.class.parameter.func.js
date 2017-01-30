module.exports = function() {
	function foo(__ks_class_1) {
		if(__ks_class_1 === undefined || __ks_class_1 === null) {
			throw new Error("Missing parameter 'class'");
		}
		console.log(__ks_class_1);
	}
}
module.exports = function() {
	var {String, __ks_String} = require("./_string")();
	function lines(value) {
		if(value === undefined || value === null) {
			throw new Error("Missing parameter 'value'");
		}
		return __ks_String._im_lines(value);
	}
}
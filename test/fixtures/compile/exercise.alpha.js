module.exports = function() {
	var Float = require("./_float.ks")().Float;
	var {Number, __ks_Number} = require("./_number.ks")();
	function alpha(n = null, percentage) {
		if(percentage === undefined || percentage === null) {
			percentage = false;
		}
		let i = Float.parse(n);
		return isNaN(i) ? 1 : __ks_Number._im_round(__ks_Number._im_limit(percentage ? i / 100 : i, 0, 1), 3);
	}
}
const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const Unit = Helper.struct(function() {
		return new OBJ();
	}, function(__ks_new, args) {
		if(args.length === 0) {
			return __ks_new();
		}
		throw Helper.badArgs();
	});
	const unit = Unit.__ks_new();
};
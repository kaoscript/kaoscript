const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(x = null) {
		const _ = new OBJ();
		_.x = x;
		return _;
	}, function(__ks_new, args) {
		if(args.length <= 1) {
			return __ks_new(args[0]);
		}
		throw Helper.badArgs();
	});
	const f = Foobar.__ks_new("");
	f.x = null;
};
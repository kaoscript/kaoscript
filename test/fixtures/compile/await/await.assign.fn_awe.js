const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var fs = require("fs");
	function read() {
		return read.__ks_rt(this, arguments);
	};
	read.__ks_0 = function(__ks_cb) {
		let data = null;
		fs.readFile("data.json", (__ks_e, __ks_0) => {
			if(__ks_e) {
				__ks_cb(__ks_e);
			}
			else {
				data = __ks_0;
				return __ks_cb(null, data);
			}
		});
	};
	read.__ks_rt = function(that, args) {
		const t0 = Type.isFunction;
		if(args.length === 1) {
			if(t0(args[0])) {
				return read.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
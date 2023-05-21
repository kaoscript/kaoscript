const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	function read() {
		return read.__ks_rt(this, arguments);
	};
	read.__ks_0 = function(filename, __ks_cb) {
		fs.readFile(filename, (__ks_e, __ks_0) => {
			if(__ks_e) {
				__ks_cb(__ks_e);
			}
			else {
				const data = __ks_0;
				return __ks_cb(null, parseInt(data.split(/\r?\n/g)[0]));
			}
		});
	};
	read.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isFunction;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return read.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};
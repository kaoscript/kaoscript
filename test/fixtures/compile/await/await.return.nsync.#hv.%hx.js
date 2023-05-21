const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var fs = require("fs");
	function read() {
		return read.__ks_rt(this, arguments);
	};
	read.__ks_0 = function() {
		fs.readFile("data.json", (__ks_e, __ks_0) => {
			const data = __ks_0;
		});
	};
	read.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return read.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};
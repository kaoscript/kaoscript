require("kaoscript/register");
var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = require("../_/_string.ks")().__ks_String;
	var exec = require("child_process").exec;
	const df_regex = /([\/[a-z0-9\-\_\s]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+(\/.*)/i;
	function disks(__ks_cb) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 0 + 1)");
		}
		else if(!Type.isFunction(__ks_cb)) {
			throw new TypeError("'callback' must be a function");
		}
		exec("df -k", (__ks_e, __ks_0) => {
			if(__ks_e) {
				__ks_cb(__ks_e);
			}
			else {
				let stdout = __ks_0;
				let disks = [];
				let matches = null;
				for(let __ks_1 = 0, __ks_2 = __ks_String._im_lines(stdout), __ks_3 = __ks_2.length, line; __ks_1 < __ks_3; ++__ks_1) {
					line = __ks_2[__ks_1];
					let __ks_4;
					if(Type.isValue(__ks_4 = df_regex.exec(line)) ? (matches = __ks_4, true) : false) {
						disks.push((() => {
							const d = new Dictionary();
							d.device = matches[1].trim();
							d.mount = matches[9];
							d.total = __ks_String._im_toInt(matches[2]) * 1024;
							d.used = __ks_String._im_toInt(matches[3]) * 1024;
							d.available = __ks_String._im_toInt(matches[4]) * 1024;
							return d;
						})());
					}
				}
				return __ks_cb(null, disks);
			}
		});
	}
	return {
		disks: disks
	};
};
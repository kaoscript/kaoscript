require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var {String, __ks_String} = require("./_string.ks")();
	var exec = require("child_process").exec;
	const df_regex = /([\/[a-z0-9\-\_\s]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+(\/.*)/i;
	function disks(__ks_cb) {
		if(arguments.length < 1) {
			let __ks_error = new SyntaxError("wrong number of arguments (" + arguments.length + " for 0 + 1)");
			if(arguments.length > 0 && Type.isFunction((__ks_cb = arguments[arguments.length - 1]))) {
				return __ks_cb(__ks_error);
			}
			else {
				throw __ks_error;
			}
		}
		else if(!Type.isFunction(__ks_cb)) {
			throw new TypeError("'callback' must be a function");
		}
		exec("df -k", (__ks_e, stdout, stderr) => {
			if(__ks_e) {
				__ks_cb(__ks_e);
			}
			else {
				let disks = [];
				let matches;
				let __ks_0 = __ks_String._im_lines(stdout);
				for(let __ks_1 = 0, __ks_2 = __ks_0.length, line; __ks_1 < __ks_2; ++__ks_1) {
					line = __ks_0[__ks_1];
					matches = df_regex.exec(line);
					if(matches) {
						disks.push({
							device: matches[1].trim(),
							mount: matches[9],
							total: __ks_String._im_toInt(matches[2]) * 1024,
							used: __ks_String._im_toInt(matches[3]) * 1024,
							available: __ks_String._im_toInt(matches[4]) * 1024
						});
					}
				}
				return __ks_cb(null, disks);
			}
		});
	}
	return {
		disks: disks
	};
}
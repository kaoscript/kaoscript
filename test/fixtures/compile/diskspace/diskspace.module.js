require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {__ks_RegExp, __ks_String, __ksType: __ksType0} = require("../_/._string.wstd.ks.j5k8r9.ksb")();
	var exec = require("child_process").exec;
	const df_regex = /([\/[a-z0-9\-\_\s]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+(\/.*)/i;
	function disks() {
		return disks.__ks_rt(this, arguments);
	};
	disks.__ks_0 = function(__ks_cb) {
		const result = [];
		exec("df -k", (__ks_e, __ks_0) => {
			if(__ks_e) {
				__ks_cb(__ks_e);
			}
			else {
				const stdout = Helper.assert(__ks_0, "\"String\"", 0, Type.isString);
				for(let __ks_3 = __ks_String.__ks_func_lines_0.call(stdout), __ks_2 = 0, __ks_1 = __ks_3.length, line; __ks_2 < __ks_1; ++__ks_2) {
					line = __ks_3[__ks_2];
					let matches, __ks_4;
					if((Type.isValue(__ks_4 = df_regex.exec(line)) ? (matches = __ks_4, true) : false)) {
						result.push((() => {
							const o = new OBJ();
							o.device = matches[1].trim();
							o.mount = matches[9];
							o.total = __ks_String.__ks_func_toInt_0.call(matches[2]) * 1024;
							o.used = __ks_String.__ks_func_toInt_0.call(matches[3]) * 1024;
							o.available = __ks_String.__ks_func_toInt_0.call(matches[4]) * 1024;
							return o;
						})());
					}
				}
				return __ks_cb(null, result);
			}
		});
	};
	disks.__ks_rt = function(that, args) {
		const t0 = Type.isFunction;
		if(args.length === 1) {
			if(t0(args[0])) {
				return disks.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		disks
	};
};
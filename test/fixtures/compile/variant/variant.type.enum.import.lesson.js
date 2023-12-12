require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {PersonKind, __ksType: __ksType0} = require("./.variant.type.enum.export.lesson.ks.j5k8r9.ksb")();
	function start() {
		return start.__ks_rt(this, arguments);
	};
	start.__ks_0 = function(lesson) {
		if(Type.isArray(lesson.students)) {
			for(let __ks_1 = 0, __ks_0 = lesson.students.length, name; __ks_1 < __ks_0; ++__ks_1) {
				({name} = lesson.students[__ks_1]);
				console.log(name);
			}
		}
		else {
			const group = lesson.students;
			console.log(group.name);
			for(let __ks_1 = 0, __ks_0 = group.students.length, name; __ks_1 < __ks_0; ++__ks_1) {
				({name} = group.students[__ks_1]);
				console.log(name);
			}
		}
	};
	start.__ks_rt = function(that, args) {
		const t0 = __ksType0[2];
		if(args.length === 1) {
			if(t0(args[0])) {
				return start.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
require("kaoscript/register");
const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	var {PersonKind, __ksType: __ksType0} = require("./.variant.type.enum.export.ks.j5k8r9.ksb")();
	function greeting() {
		return greeting.__ks_rt(this, arguments);
	};
	greeting.__ks_0 = function(person) {
		let __ks_0;
		if(person.kind === PersonKind.Teacher) {
			__ks_0 = "Hey Professor!";
		}
		else if(person.kind === PersonKind.Director) {
			__ks_0 = "Hello Director.";
		}
		else if(person.kind === PersonKind.Student && person.name === "Richard") {
			__ks_0 = "Still here Ricky?";
		}
		else if(person.kind === PersonKind.Student) {
			__ks_0 = "Hey, " + person.name + ".";
		}
		return __ks_0;
	};
	greeting.__ks_rt = function(that, args) {
		const t0 = __ksType0[0];
		if(args.length === 1) {
			if(t0(args[0])) {
				return greeting.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const person = (() => {
		const o = new OBJ();
		o.kind = PersonKind.Student;
		o.name = "Richard";
		return o;
	})();
	console.log(greeting.__ks_0(person));
};
require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var {Position, Range, PersonKind, SchoolPerson} = require("./.variant.type.enum.fusion.export.alias.ks.j5k8r9.ksb")();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(student) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => SchoolPerson.is(value, 0, value => value === PersonKind.Student);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	const __ksType = {
		isSchoolPerson: (value, cast) => Type.isDexObject(value, 1, 0, {kind: () => Helper.castEnum(value, "kind", PersonKind, cast), name: Type.isString})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	function restore() {
		return restore.__ks_rt(this, arguments);
	};
	restore.__ks_0 = function(student) {
		student = Helper.assert(student, "\"SchoolPerson\"", 0, value => __ksType.isSchoolPerson(value, true));
	};
	restore.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return restore.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let data = (() => {
		const o = new OBJ();
		o.kind = 2;
		o.name = "John";
		return o;
	})();
	expect(data.kind).to.equal(2);
	expect(data.kind).to.not.equal(PersonKind.Student);
	console.log(data);
	restore.__ks_0(data);
	console.log(data);
	expect(data.kind).to.not.equal(2);
	expect(data.kind).to.equal(PersonKind.Student);
};
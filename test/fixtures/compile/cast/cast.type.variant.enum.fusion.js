const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	const __ksType = {
		isPerson: value => Type.isDexObject(value, 1, 0, {name: Type.isString}),
		isSchoolPerson: (value, cast, filter) => __ksType.isPerson(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
			if(cast) {
				if((variant = PersonKind(variant)) === null) {
					return false;
				}
				value["kind"] = variant;
			}
			else if(!Type.isEnumInstance(variant, PersonKind)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant === PersonKind.Student) {
				return Type.isDexObject(value, 0, 0, {age: Type.isNumber});
			}
			if(variant === PersonKind.Teacher) {
				return Type.isDexObject(value, 0, 0, {favorite: __ksType.isSchoolPerson});
			}
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	function restore() {
		return restore.__ks_rt(this, arguments);
	};
	restore.__ks_0 = function(student) {
		student = __ksType.isSchoolPerson(student, true) ? student : null;
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
		o.kind = 3;
		o.favorite = (() => {
			const o = new OBJ();
			o.kind = 2;
			o.name = "John";
			return o;
		})();
		return o;
	})();
	expect(data.favorite.kind).to.equal(2);
	expect(data.favorite.kind).to.not.equal(PersonKind.Student);
	console.log(data);
	restore.__ks_0(data);
	console.log(data);
	expect(data.favorite.kind).to.not.equal(2);
	expect(data.favorite.kind).to.equal(PersonKind.Student);
};
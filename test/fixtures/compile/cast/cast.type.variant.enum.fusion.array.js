const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	const Person = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString}));
	const SchoolPerson = Helper.alias((value, cast, filter) => Person.is(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
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
			return Type.isDexObject(value, 0, 0, {name: Type.isString});
		}
		if(variant === PersonKind.Teacher) {
			return Type.isDexObject(value, 0, 0, {favorites: value => Type.isArray(value, value => SchoolPerson.is(value, cast))});
		}
		return true;
	}}));
	function restore() {
		return restore.__ks_rt(this, arguments);
	};
	restore.__ks_0 = function(student) {
		student = Helper.assert(student, "\"SchoolPerson\"", 0, value => SchoolPerson.is(value, true));
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
		o.favorites = [(() => {
			const o = new OBJ();
			o.kind = 2;
			o.name = "John";
			return o;
		})()];
		return o;
	})();
	expect(data.favorites[0].kind).to.equal(2);
	expect(data.favorites[0].kind).to.not.equal(PersonKind.Student);
	console.log(data);
	restore.__ks_0(data);
	console.log(data);
	expect(data.favorites[0].kind).to.not.equal(2);
	expect(data.favorites[0].kind).to.equal(PersonKind.Student);
};
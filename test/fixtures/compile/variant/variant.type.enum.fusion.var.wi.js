const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPerson: value => Type.isDexObject(value, 1, 0, {name: Type.isString})
	};
	const PersonKind = Helper.enum(Number, {
		Director: 1,
		Student: 2,
		Teacher: 3
	});
	const person = (() => {
		const o = new OBJ();
		o.kind = PersonKind.Student;
		o.name = "Richard";
		return o;
	})();
};
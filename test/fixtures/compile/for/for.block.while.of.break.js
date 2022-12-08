const {Helper, OBJ, Operator} = require("@kaoscript/runtime");
module.exports = function() {
	let likes = (() => {
		const d = new OBJ();
		d.leto = "spice";
		d.paul = "chani";
		d.duncan = "murbella";
		return d;
	})();
	for(let key in likes) {
		let value = likes[key];
		if(!(Operator.lte(value.length, 5))) {
			break;
		}
		console.log(Helper.concatString(key, " likes ", value));
	}
};
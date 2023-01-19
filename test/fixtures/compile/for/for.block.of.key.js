const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	for(let key in likes) {
		console.log(key);
	}
};
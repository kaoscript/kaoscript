module.exports = function() {
	var Module = require("module");
	const m = new Module("eval");
	m.filename = "test";
};
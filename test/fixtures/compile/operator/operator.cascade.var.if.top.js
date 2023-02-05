const {Operator} = require("@kaoscript/runtime");
module.exports = function(Ellipse, filterRotate) {
	const shape = new Ellipse(10, 20);
	filterRotate() ? shape.rotation = Operator.division(Operator.multiplication(45, Math.PI), 180) : null;
	shape.color = "rgb(0,129,198)";
	shape.outlineWidth = 0;
};
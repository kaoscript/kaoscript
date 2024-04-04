module.exports = function(Ellipse, filterRotate) {
	const shape = new Ellipse(10, 20);
	filterRotate(shape) ? shape.rotation = (45 * Math.PI) / 180 : null;
	shape.color = "rgb(0,129,198)";
	shape.outlineWidth = 0;
};
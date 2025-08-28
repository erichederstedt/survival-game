package renderer;

typedef GL = js.html.webgl.WebGL2RenderingContext;

function glEnumToString(glEnum:Int):String {
	final glEnums = Reflect.fields(GL);
	for (glEnumName in glEnums) {
		if (Reflect.field(GL, glEnumName) == glEnum)
			return glEnumName;
	}
	return "";
}

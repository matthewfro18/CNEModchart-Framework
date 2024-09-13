package modchart.core.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Expr.FieldType;

class Macro
{
	/*
	// thanks god i know macros
	public static function buildModifiers():Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();
		var modifierList:Array<Class<Modifier>> = CompileTime.getClassList('modchart.modifiers');
		var mappedModifiers:Map<String, Class<Modifier>> = [];

		for (i in 0...modifierList.length)
		{
			var cls = modifierList[i];

			var name = Type.getClassName(cls);
			name = name.substring(name.lastIndexOf('.') + 1);
			mappedModifiers.set(name.toLowerCase(), cls);
		}

		fields.push({
			name: "GLOBAL_MODIFIERS",
			access: [APublic, AStatic],
			kind: FieldType.FVar(macro:Map<String, Class<Modifier>>, macro $v{mappedModifiers}),
			pos: Context.currentPos()
		});

		Context.info('---- Current Modifiers ----\n$mappedModifiers');
		return fields;
	}*/
    public static function includeClasses()
    {
        Compiler.include('modchart');
    }
}
#end
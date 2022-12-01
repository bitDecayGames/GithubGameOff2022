package shaders;

import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class Greyen extends FlxShader
{
	@:glFragmentSource('
        #pragma header

        uniform bool isShaderActive;

        void main()
        {
            vec4 pixel = texture2D(bitmap, openfl_TextureCoordv);
            if (pixel.a != 0.0) {
                gl_FragColor.rgb = vec3(0.2, 0.2, 0.2);
            }
        }')

    public function new()
    {
        super();
    }
}
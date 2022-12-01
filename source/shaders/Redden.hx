package shaders;

import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class Redden extends FlxShader
{
	@:glFragmentSource('
        #pragma header

        uniform bool isShaderActive;

        void main()
        {
            vec4 pixel = texture2D(bitmap, openfl_TextureCoordv);
            if (pixel.a != 0.0) {
                pixel.r *= 1.5;
                // pixel.rgb *= vec3(1.0, 0.6, 0.6);
                // pixel.rgb *= 1.5;
                gl_FragColor = pixel;
            }
        }')

    public function new()
    {
        super();
    }
}
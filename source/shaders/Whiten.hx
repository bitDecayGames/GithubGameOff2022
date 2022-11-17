package shaders;

import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class Whiten extends FlxShader
{
	@:glFragmentSource('
        #pragma header

        uniform bool isShaderActive;

        void main()
        {
            vec4 pixel = texture2D(bitmap, openfl_TextureCoordv);

			if (!isShaderActive)
			{
				gl_FragColor = pixel;
				return;
            } 

            if (pixel.a != 0.0) {
                gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
            }
        }')

    public function new()
    {
        super();
    }
}
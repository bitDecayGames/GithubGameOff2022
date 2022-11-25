package shaders;

import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class Lighten extends FlxShader
{
	@:glFragmentSource('
        #pragma header

        uniform float iTime;
        uniform float lightSourceX;
        uniform float lightSourceY;
        uniform float lightRadius;

        uniform bool fireActive;
        uniform float lightSourceFireX;
        uniform float lightSourceFireY;
        uniform float lightFireRadius;
        uniform bool isShaderActive;

        void main()
        {
            // This should be available as a built in, but where?
            vec2 ingameResolution = vec2(256, 244);
            vec2 uv = openfl_TextureCoordv;
            vec4 pixel = texture2D(bitmap, openfl_TextureCoordv);

			if (!isShaderActive)
			{
				gl_FragColor = pixel;
				return;
            }

            vec2 uvInGameRes = vec2(floor(uv.x * ingameResolution.x), floor(uv.y * ingameResolution.y));


            vec2 lightSourceVector = vec2(floor(lightSourceX), floor(lightSourceY));

            // the distance from the light source as a value from 0 to 1
            // a value of (.5, .5) would mean the distance between the pixel and light source is half the distance of the entire screen
            float dist = floor(length(lightSourceVector - uvInGameRes));

            if (dist >= lightRadius) {
                pixel = vec4(0, 0, 0, 1.0);
            } else {
                pixel.rgb *= 0.33;
            }

            if (fireActive) {
                vec2 lightSourceFireVector = vec2(floor(lightSourceFireX), floor(lightSourceFireY));
                float dist2 = floor(length(lightSourceFireVector - uvInGameRes));
                if (dist2 <= lightRadius) {
                    pixel = texture2D(bitmap, openfl_TextureCoordv);
                    pixel.rgb *= .45;
                }
            }

			gl_FragColor = pixel;
        }')

    public function new()
    {
        super();
    }
}
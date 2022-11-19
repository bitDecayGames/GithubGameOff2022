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

            vec2 lightSourceVector = vec2(floor(lightSourceX), floor(lightSourceY));
            vec2 uvInGameRes = vec2(floor(uv.x * ingameResolution.x), floor(uv.y * ingameResolution.y));

            // the distance from the light source as a value from 0 to 1
            // a value of (.5, .5) would mean the distance between the pixel and light source is half the distance of the entire screen
            vec2 dist = lightSourceVector - uvInGameRes;

            // Adjust for screen aspect ratio
            float distanceFromLightSource = floor(length(dist));

            if (distanceFromLightSource >= lightRadius) {
                pixel = vec4(0, 0, 0, 1.0);
            } else {
                pixel = pixel * 0.33;
            }
			gl_FragColor = pixel;
        }')

    public function new()
    {
        super();
    }
}
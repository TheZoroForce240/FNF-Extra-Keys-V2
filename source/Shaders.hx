package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;


class HSVEffect
{
    public var shader:HSVShader = new HSVShader();
	public var hue:Float = 0;
	public var saturation:Float = 0;
	public var brightness:Float = 0;
    public function new(){
        shader.hsvChange.value = [0, 0, 0];
    }
  
    public function update(){
        shader.hsvChange.value = [hue, saturation, brightness];
    }
}
// got the shit from here // had to edit it a bit
//https://gamedev.stackexchange.com/questions/59797/glsl-shader-change-hue-saturation-brightness
class HSVShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

        
        vec3 rgb2hsv(vec3 c)
        {
            vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
            vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
        
            float d = q.x - min(q.w, q.y);
            float e = 1.0e-10;
            return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
        }
        
        vec3 hsv2rgb(vec3 c)
        {
            vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
            return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
        }

        uniform vec3 hsvChange;

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            vec4 hsvColor = vec4(rgb2hsv(vec3(color[0], color[1], color[2])), color[3]);

            hsvColor[0] = hsvColor[0] + hsvChange[0];           //hue
            hsvColor[1] = hsvColor[1] + hsvChange[1];           //sat
            hsvColor[2] = hsvColor[2] * (1.0 + hsvChange[2]);   //bright
                                                                //shouldnt it be hsb wtf???
            color = vec4(hsv2rgb(vec3(hsvColor[0], hsvColor[1], hsvColor[2])), hsvColor[3]);
            gl_FragColor = color;
        } 

    
    ')
    public function new()
        {
          super();
        } 
}
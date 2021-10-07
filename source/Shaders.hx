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
class SoundEffect
{
    public var shader:SoundShader = new SoundShader();
    public var resx:Float = 0;
    public var resy:Float = 0;
    public var amp:Float = 0;
    public function new(){
        shader.uresolution.value = [0, 0];
        shader.soundShit.value = [0];
    }
  
    public function update(){
        shader.uresolution.value = [resx, resy];
        shader.soundShit.value = [amp];
    }
}

//https://www.shadertoy.com/view/NdK3zW
class SoundShader extends FlxShader //will make it work at some point
{
    @:glFragmentSource('
    #pragma header

        
    #define PI 3.14159
    #define TWO_PI 6.28318
    #define LINE_WIDTH 12
    #define LINE_HEIGHT 200
    #define LINE_PLACE (LINE_WIDTH + LINE_OFFSET)
    #define LINE_OFFSET 4
    #define FREQ 512.0

    uniform float uresolution
    uniform float soundShit

    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

    fragCoord = color;
    
    vec3 rectangle(int x, int y, int width, int height, ivec2 fragCoord)
    {
        if(fragCoord.x >= x && fragCoord.y >= y && fragCoord.x <= x + width && fragCoord.y <= y + height)
            return vec3(1);
        return vec3(0);
    }
    
    vec3 rgb2hsv(vec3 c)
    {
        vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
        vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
        vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
        float d = q.x - min(q.w, q.y);
        float e = 1.0e-10;
        return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    }
    
    float frequency(int x)
    {
        return texelFetch(soundShit, ivec2(x, 0), 0).r;
    }
    
    float lerp4(const float[4] points, float inBetween) 
    { 
        float scaledInBetween = inBetween * 3.0;
        float newInBetween = scaledInBetween - floor(scaledInBetween);
        float start = points[min(int(scaledInBetween), 3)];
        float end = points[min(int(scaledInBetween + 1.0f), 3)];
        return mix(start, end, newInBetween);
    }
    
    float smoothFrequency(int x, int smoothness)
    {
        float f = 0.0;
        int accumulated = 0;
        for(int i = 0; i <= smoothness; ++i)
        {
            if(x + i > int(FREQ) || x + i < 0) continue;
            f += frequency(x + i);
            ++accumulated;
        }
        return f / float(accumulated);
    }
     
    
    // All components are in the range [0…1], including hue.
    vec3 hsv2rgb(vec3 c)
    {
        vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
        vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
        return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }
    
    void mainImage( out vec4 fragColor, in vec2 fragCoord )
    {
        vec2 uv = openfl_TextureCoordv;
        
        float d = FREQ / uresolution.x;
        float f = uresolution.x / float(LINE_PLACE);
        int numLines = int(f);
        float multiplier = FREQ / f;
    
        vec3 col = vec3(0);
        int x = int(float(int(uv.x * f)) * multiplier);
        float freq = smoothFrequency(x, int(float(LINE_PLACE) * d));
        float wave = texelFetch(soundShit, ivec2(int(uv.x * FREQ), 1), 0).r;
        
        int freqHeight = int(freq * float(LINE_HEIGHT));
        
        for(int i = 0; i <= numLines; ++i)
        col += rectangle(i * LINE_PLACE, 0, LINE_WIDTH, freqHeight, ivec2(fragCoord));
        
        col *= hsv2rgb(vec3(float(x) / FREQ, 1.0, 1.0));
        
        fragColor = vec4(col,color.a);
    } 

    
    ')
    public function new()
        {
          super();
        } 
}
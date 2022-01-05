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


class RayMarchEffect
{
    public var shader:RayMarchShader = new RayMarchShader();
	public var x:Float = 0;
	public var y:Float = 0;
    public function new(){
        shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
        shader.ShaderPointShit.value = [0, 0];
    }
  
    public function update(){
        shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
    }

    public function setPoint(){
        shader.ShaderPointShit.value = [x, y];
    }
}
//il get this to work at some point lol
class RayMarchShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    // "RayMarching starting point" 
    // by Martijn Steinrucken aka The Art of Code/BigWings - 2020
    // The MIT License
    // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    // Email: countfrolic@gmail.com
    // Twitter: @The_ArtOfCode
    // YouTube: youtube.com/TheArtOfCodeIsCool
    // Facebook: https://www.facebook.com/groups/theartofcode/
    //
    // You can use this shader as a template for ray marching shaders

    #define MAX_STEPS 100
    #define MAX_DIST 100.
    #define SURF_DIST .001

    #define S smoothstep
    #define T iTime

    uniform vec2 ShaderPointShit;
    uniform vec3 iResolution;

    mat2 Rot(float a) {
        float s=sin(a), c=cos(a);
        return mat2(c, -s, s, c);
    }

    float sdBox(vec3 p, vec3 s) {
        p = abs(p)-s;
        return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
    }


    float GetDist(vec3 p) {
        float d = sdBox(p, vec3(flixel_texture2D(bitmap, openfl_TextureCoordv).xyz));
        
        return d;
    }

    float RayMarch(vec3 ro, vec3 rd) {
        float dO=0.;
        
        for(int i=0; i<MAX_STEPS; i++) {
            vec3 p = ro + rd*dO;
            float dS = GetDist(p);
            dO += dS;
            if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
        }
        
        return dO;
    }

    vec3 GetNormal(vec3 p) {
        float d = GetDist(p);
        vec2 e = vec2(.001, 0);
        
        vec3 n = d - vec3(
            GetDist(p-e.xyy),
            GetDist(p-e.yxy),
            GetDist(p-e.yyx));
        
        return normalize(n);
    }

    vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z) {
        vec3 f = normalize(l-p),
            r = normalize(cross(vec3(0,1,0), f)),
            u = cross(f,r),
            c = f*z,
            i = c + uv.x*r + uv.y*u,
            d = normalize(i);
        return d;
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;
        vec2 m = ShaderPointShit.xy/iResolution.xy;

        vec3 ro = vec3(0, 0, 0);
        ro.yz *= Rot(-m.y*3.14+1.);
        ro.xz *= Rot(-m.x*6.2831);
        
        vec3 rd = GetRayDir(uv, ro, vec3(0,0.,0), 1.);
        vec3 col = vec3(0);
    
        float d = RayMarch(ro, rd);

        if(d<MAX_DIST) {
            vec3 p = ro + rd * d;
            vec3 n = GetNormal(p);
            vec3 r = reflect(rd, n);

            float dif = dot(n, normalize(vec3(1,2,3)))*.5+.5;
            col = vec3(dif);
        }
        
        col = pow(col, vec3(.4545));	// gamma correction
        
        gl_FragColor = vec4(col,1.0);
    }')
    public function new()
        {
          super();
        } 
}
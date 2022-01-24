package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;


//for anyone lookin through the shaders idc if you use the code just credit lol

//also this helped a lot https://www.shadertoy.com/view/Md23DV
//useful for anyone wanting to learn how to make shaders


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
        shader.ShaderPointShit.value = [x*(Math.PI/180), y*(Math.PI/180)];
    }
}
//il get this to work at some point lol

//shader from here: https://www.shadertoy.com/view/WtGXDD

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
        float d = sdBox(p, vec3(1));
        
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

    void main() //this shader is pain
    {
        vec2 center = vec2(0.5, 0.5);
        //vec2 uv = (openfl_TextureCoordv.xy * iResolution.xy); //apparently this moves it to the center?????? no fuck you
        //uv = 2.0 * uv.xy / iResolution.xy;
        //vec2 m = ShaderPointShit.xy/iResolution.xy;
        vec2 uv = openfl_TextureCoordv.xy - center;

        vec3 ro = vec3(0, 0, -3); //ok so -2 is the correct zoom

        ro.yz *= Rot(ShaderPointShit.y); //rotation shit
        ro.xz *= Rot(ShaderPointShit.x);
        
        vec3 rd = GetRayDir(uv, ro, vec3(0,0.,0), 1.);
        vec4 col = vec4(0);
    
        float d = RayMarch(ro, rd);

        if(d<MAX_DIST) {
            vec3 p = ro + rd * d;

            //vec3 n = GetNormal(p);  
            //vec3 r = reflect(rd, n);
            //float dif = dot(n, normalize(vec3(1,2,3)))*.5+.5;

            //uv = vec2(n.x,n.y);
            //uv = vec2(p.x,p.y) + iResolution.xy;

            //uv = (vec2(p.x,p.y) / iResolution.xy);
            uv = vec2(p.x,p.y) / 2;
            uv += center; //move coords from top left to center
            col = flixel_texture2D(bitmap, uv); //shadertoy to haxe bullshit i barely understand
        }
        
        //col = pow(col, vec4(.4545));	// gamma correction
        // makes the colour look fuckin weird
        
        gl_FragColor = col;
        //gl_FragDepth = 2;
    }')
    public function new()
        {
          super();
        } 
}




class ColorToggleEffect //remove all of a certain color or give a color more influence over others
{
    public var shader:ColorToggleShader = new ColorToggleShader();
	public var r:Float = 1;
	public var g:Float = 1;
    public var b:Float = 1;
    public function new(){
        shader.colorShit.value = [1,1,1];
    }
  
    public function update(){
        shader.colorShit.value = [r,g,b];
    }
}
class ColorToggleShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    uniform vec3 colorShit;

    void main()
    {
        vec2 uv = (openfl_TextureCoordv);
        vec4 col = flixel_texture2D(bitmap, uv);
        gl_FragColor = vec4(col.r * colorShit[0], col.g * colorShit[1], col.b * colorShit[2], col.a);
    }')
    public function new()
    {
        super();
    } 
}


class GradientShitEffect ///made this on accident, thought it looked cool
{                       
    public var shader:GradientShitShader = new GradientShitShader();
	public var effect:Float = 1;

    public function new(){
        shader.effect.value = [1];
    }
  
    public function update(){
        shader.effect.value = [effect];
    }
}
class GradientShitShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    uniform float effect;

    void main()
    {
        vec2 uv = (openfl_TextureCoordv);
        vec4 col = flixel_texture2D(bitmap, uv);

        col.r = vec2(uv + 0.01 * effect);
        col.b = vec2(uv - 0.01 * effect);


        gl_FragColor = vec4(col);
    }')
    public function new()
    {
        super();
    } 
}



class GlitchInvertEffect
{                       
    public var shader:GlitchInvertShader = new GlitchInvertShader();
    public var speed:Float = 50; ///this is a percentage change per frame

    public function new(){
        shader.effect1.value = [0,0,0];
        shader.effect2.value = [0,0,0];
        shader.effect3.value = [0,0,0];
    }
  
    public function update(){   //a little annoying but whatever

        var chanceToUpdate = false;
        if (speed == 0) //so it can be turned off
        {
            shader.effect1.value = [0,0,0];
            shader.effect2.value = [0,0,0];
            shader.effect3.value = [0,0,0];
        }
        else 
            chanceToUpdate = FlxG.random.bool(speed);
        

        if (chanceToUpdate)
        {
            var num1 = FlxG.random.float(0, 0.2);
            var num2 = FlxG.random.float(num1, 0.3);
            var isbox1inverted = FlxG.random.int(0, 1);
    
            var num3 = FlxG.random.float(num2, 0.5);
            var num4 = FlxG.random.float(num3, 0.6);
            var isbox2inverted = FlxG.random.int(0, 1);
    
            var num5 = FlxG.random.float(num4, 0.8);
            var num6 = FlxG.random.float(num5, 1);
            var isbox3inverted = FlxG.random.int(0, 1);

            shader.effect1.value = [num1, num2, isbox1inverted];
            shader.effect2.value = [num3, num4, isbox2inverted];
            shader.effect3.value = [num5, num6, isbox3inverted];
        }

    }
}
class GlitchInvertShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    uniform vec3 effect1;
    uniform vec3 effect2;
    uniform vec3 effect3;

    void main()
    {
        vec2 uv = (openfl_TextureCoordv);

        if (uv.y > effect1[0] && uv.y < effect1[1])     //offsets
            uv.x += 0.1;
        else if (uv.y > effect2[0] && uv.y < effect2[1])
            uv.x -= 0.1;
        else if (uv.y > effect3[0] && uv.y < effect3[1])
            uv.x += 0.1;
        
        vec4 col = flixel_texture2D(bitmap, uv);

        if (uv.y > effect1[0] && uv.y < effect1[1] && effect1[2] == 1)     //color invert
            col = vec4(vec3(1.0, 1.0, 1.0) - col.rgb, col.a);
        else if (uv.y > effect2[0] && uv.y < effect2[1] && effect2[2] == 1)
            col = vec4(vec3(1.0, 1.0, 1.0) - col.rgb, col.a);
        else if (uv.y > effect3[0] && uv.y < effect3[1] && effect3[2] == 1)
            col = vec4(vec3(1.0, 1.0, 1.0) - col.rgb, col.a);

        gl_FragColor = vec4(col);
    }')
    public function new()
    {
        super();
    } 
}
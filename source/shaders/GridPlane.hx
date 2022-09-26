package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class GridPlane
{
	public var shader(default, null):GridPlaneShader = new GridPlaneShader();

	public function new(ratio:Float = 30, color:FlxColor = FlxColor.BLACK):Void
	{
		setRatio(ratio);
		setColor(color);
	}

	public function setRatio(ratio:Float):Void
	{
		shader.ratio.value = [ratio];
	}

	public function setColor(color:FlxColor):Void
	{
		shader.color.value = [0, color.redFloat + 1, color.blueFloat + 1, color.greenFloat + 1];
	}
}

// STOLEN FROM https://www.shadertoy.com/view/7t2SWy LOL
// it doesn't work on html5 for some reasons
class GridPlaneShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float ratio;
		uniform vec4 color;

		float grid_texture(in vec2 p, in vec2 ddx, in vec2 ddy)
		{
			// filter kernel
			vec2 w = max(abs(ddx), abs(ddy)) + 0.01;

			// analytic (box) filtering
			vec2 a = p + 0.5 * w;                        
			vec2 b = p - 0.5 * w;           
			vec2 i = (floor(a) + min(fract(a) * ratio,1.0) -
				floor(b) - min(fract(b) * ratio, 1.0)) / (ratio * w);
			// pattern
			return (1.0-i.x)*(1.0-i.y);
		}

		float intersect(vec3 ro, vec3 rd, out vec3 pos, out int matid)
		{
			// raytrace
			float tmin = 10000.0;
			pos = vec3(0.0);
			matid = -1;

			// raytrace-plane
			float h = -ro.y / rd.y;
			if (h > 0.0)
			{ 
				tmin = h; 
				pos = ro + h * rd;
				matid = 0;
			}

			return tmin;	
		}

		void calc_ray_for_pixel(in vec2 pix, out vec3 resRo, out vec3 resRd)
		{
			vec2 p = -((2.0 * pix-openfl_TextureSize.xy) / openfl_TextureSize.y);

			// camera movement	
			vec3 ro = vec3(0., 1., 0.);
			vec3 ta = vec3(0., 0., 10000.);
			// camera matrix
			vec3 ww = normalize(ta - ro);
			vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
			vec3 vv = normalize(cross(uu, ww));
			// create view ray
			vec3 rd = normalize(p.x * uu + p.y * vv + 2.0 * ww);

			resRo = ro;
			resRd = rd;
		}

		void main()
		{
			vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;

			vec2 p = (-openfl_TextureSize.xy + 2.0 * fragCoord) / openfl_TextureSize.y;

			vec3 ro, rd;
			calc_ray_for_pixel(fragCoord + vec2(0.0, 0.0), ro, rd);

			// trace
			vec3 pos;
			int mid;
			float t = intersect(ro, rd, pos, mid);

			vec4 col = vec4(.0);
			if (mid != -1)
			{
				// shading
				vec2 uv;
				if (mid == 0)
					uv = pos.xz;
				float a = grid_texture(uv, dFdx(uv), dFdy(uv));
				col = a * col + (1. - a) * color;
			}

			gl_FragColor = col;
		}')
	public function new()
	{
		super();
	}
}

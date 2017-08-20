Shader "LineLights" {
	Properties{
		lh("Height",range(0,4)) = 1
		li("Strong",range(0,20)) = 1
	}
		SubShader{
		pass {
		Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma target 3.0
			#include "UnityCG.cginc"

			struct v2f 
			{
				float4 pos:SV_POSITION;
				float3 wN:TEXCOORD0;
				float4 wP:TEXCOORD1;
			};
			float4 litP;
			float4 litT;
			float4 litN;
			float lh;
			float li;
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.wN = mul(unity_ObjectToWorld,float4(SCALED_NORMAL,0)).xyz;
				o.wP = mul(unity_ObjectToWorld,v.vertex);
				return o;
			}
			float4 frag(v2f i) :COLOR
			{
				float3 litDir = litP.xyz - i.wP.xyz / i.wP.w;
				float3 litDir1 = litP.xyz + litT.xyz*lh - i.wP.xyz / i.wP.w;
				float3 litDir2 = litP.xyz - litT.xyz*lh - i.wP.xyz / i.wP.w;
				float len1 = length(litDir1);
				float len2 = length(litDir2);
				float len = abs(len1*len1 - len2*len2) - 4 * lh*lh;
				float diff = 0;
				float att = 1;
				float3 dir = 0;
				if(len<0)
				{
					float dt = abs(dot(normalize(litDir1),litT.xyz));
					float3 horT = dt*length(litDir1)*litT.xyz;
					float3 Ldir = litDir1 - horT;

					dir = Ldir;
					float diffN = abs(dot(litN, normalize(dir)));
					diff = dot(normalize(i.wN), normalize(dir));
					diff = (diff + 0.7) / 1.7;
					diff = diff*diffN;
					att = 1 / (1 + length(dir));
					att = att*att;
				}
				else
				{
					if (len1<len2)
						dir = litDir1;
					else
						dir = litDir2;
					att = 1 / (1 + length(dir));
					att = att*att;
					float diffN = abs(dot(litN, normalize(dir)));
					diff = dot(normalize(i.wN),normalize(dir));
					diff = (diff + 0.7) / 1.7;
					diff = diff*diffN;

				}
				float c = li*diff*att;
				//float4 color = float4(c, sin(c), cos(c), 1.0);
				return c;
			}
			ENDCG
	}
	}
}


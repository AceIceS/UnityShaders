Shader "Unlit/AlphaTest"
{
    Properties
    {
		_Color("Color Tint",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
		_Cutoff("Alpha Cutoff",FLoat) = 0.5

    }
    SubShader
    {
        Tags
		{
			"Queue" = "AlphaTest"
			"RenderType"="TransparentCutout"
			"IgnoreProjector" = "True"
		}
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			Cull Off
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

#include"Lighting.cginc"

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXDOORD1;
				float3 worldPos : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;
			fixed4 _Color;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			fixed4 texColor = tex2D(_MainTex, i.uv);

			clip(texColor.a - _Cutoff);
			//if (texColor.r + texColor.g + texColor.b == 0)discard;

			fixed3 albedo = texColor.rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			fixed3 diffuse = _LightColor0.rgb * albedo *
				max(0, dot(worldLightDir, worldNormal));


			return fixed4(ambient + diffuse, 1.0);
			}
			ENDCG
		}

        Pass
        {
			Tags{"LightMode" = "ForwardBase"}

			Cull Off
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

#include"Lighting.cginc"

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float3 worldNormal : TEXDOORD1;
				float3 worldPos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _Cutoff;
			fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			fixed4 texColor = tex2D(_MainTex, i.uv);

			clip(texColor.a - _Cutoff);
			//if (texColor.r + texColor.g + texColor.b == 0)discard;

			fixed3 albedo = texColor.rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			fixed3 diffuse = _LightColor0.rgb * albedo *
				max(0, dot(worldLightDir, worldNormal));


			return fixed4(ambient + diffuse, 1.0);
            }
            ENDCG
        }
    }
			Fallback"Transparent/Cutout/VertexLit"
}

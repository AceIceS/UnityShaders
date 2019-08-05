Shader "Unlit/AlphaBlend"
{
    Properties
    {
		_Color("Colot Tint",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
		_AlphaScale("Alpha Scale",Range(0,1.0)) = 1.0
    }
    SubShader
    {
        Tags 
			{
				"Queue" = "Transparent"
				"RenderType"="Transparent"
				"IgnoreProjector" = "True"
			}

			 Pass
		{
				Tags{"LightMode" = "ForwardBase"}
				Cull Front
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

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
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _AlphaScale;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			fixed4 texColor = tex2D(_MainTex, i.uv);

			//if (texColor.r + texColor.g + texColor.b == 0)
			//	discard;

			fixed3 albedo = texColor.rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			fixed3 diffuse = _LightColor0.rgb * albedo *
				max(0, dot(worldLightDir,worldNormal));


			return fixed4(ambient + diffuse, _AlphaScale * texColor.a);
			}
			ENDCG
		}

        Pass
        {
				Tags{"LightMode" = "ForwardBase"}

				Cull Back
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

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
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Color;
			fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			fixed4 texColor = tex2D(_MainTex, i.uv);

			//if (texColor.r + texColor.g + texColor.b == 0)
			//	discard;

			fixed3 albedo = texColor.rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			fixed3 diffuse = _LightColor0.rgb * albedo *
				max(0, dot(worldLightDir,worldNormal));


			return fixed4(ambient + diffuse, _AlphaScale * texColor.a);
            }
            ENDCG
        }
    }
			Fallback"Transparent/VertexLit"
}

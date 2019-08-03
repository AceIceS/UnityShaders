Shader "Unlit/NormalMapTangentSpace"
{
    Properties
    {
		_Color("Color Tint",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        
        Pass
        {
			Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
#include"Lighting.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;//float4 , .w for vice tagent direction : y axis 
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
            };

			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;


            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
				//float3 binormal = cross(normalize(v.tangent.xyz), normalize(v.normal)) * v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
				//TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;


                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{

				fixed3 tangentLightDir = normalize(i.lightDir);
			fixed3 tangentViewDir = normalize(i.viewDir);

			fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);//raw information from normal map
			fixed3 tangentNormal;
			//the texture is not marked as NormalMap in insepector
			//tangentNormal.xy = _BumpScale * (packedNormal.xy * 2 - 1);
			//tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
			//teh texture is marked as NormalMap ,use build-in function
			tangentNormal  = UnpackNormal(packedNormal);
			tangentNormal.xy *= _BumpScale;
			tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
			
			fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;

			fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentLightDir,tangentNormal));

			fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
			fixed3 specular = _LightColor0.rgb * _Specular.rgb *
				pow(max(0,dot(halfDir,tangentNormal)),_Gloss);


			return fixed4(ambient + diffuse + specular,1.0f);
            }
            ENDCG
        }
    }

			Fallback"Specular"
}

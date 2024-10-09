Shader "Unlit/Wind"
{
    Properties
    {
        
        _Color("Color",Color) = (1,1,1,1)
        _NoiseTex1 ("NoiseTex1", 2D) = "black" {}
        _NoiseTex2 ("NoiseTex2", 2D) = "black" {}
        
        _Speed ("Speed",float) = 1
        _NoiseWeight("NoiseWeight",Range(0,1))=1
        _AlphaSmooth("AlphaSmooth",int) =3
        _Magnitude("Magnitude",float) =1.5
        _Offset("Offset",Range(-1,1)) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" 
                "Queue"="Transparent"    
             }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        // Cull On

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _NoiseTex1;
            sampler2D _NoiseTex2;
            float4 _Color;
            float _Speed;
            float _NoiseWeight;
            int _AlphaSmooth;
            float _Magnitude;
            float _Offset;


            v2f vert (appdata v)
            {
                v2f o;
                float4 localPos = v.vertex;
                float2 noiseUv = float2(frac(_Time.y*_Speed -v.uv.x),frac(_Time.y*_Speed +v.uv.y));
                float texVert=tex2Dlod(_NoiseTex1,float4(noiseUv,0,0)).r;
                float texVert2=tex2Dlod(_NoiseTex2,float4(noiseUv,0,0)).r;

                float offsetVert = texVert*_NoiseWeight + texVert2*(1-_NoiseWeight);

                localPos.y += offsetVert * (v.uv.x) * _Magnitude;
                o.vertex = UnityObjectToClipPos(localPos);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color;
                col +=  clamp(pow(1-i.uv.x,2) ,0,1);    
                
                if(i.uv.x>0.99)
                    col.a = 0;
                else
                    col.a = pow((1-i.uv.x),_AlphaSmooth);

                if(i.uv.y<0.1){
                    col.a*= pow(i.uv.y*10,2);                    
                }
                if(i.uv.y>0.9){
                    col.a*= pow((1-i.uv.y)*10,2);                    
                }               

                return col;
            }
            ENDCG
        }
    }
}

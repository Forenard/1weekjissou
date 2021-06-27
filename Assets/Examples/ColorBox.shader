Shader "PostEffect/ColorBox"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _T ("Time", Float) = 0.0
        [MaterialToggle] _IsTransitionIn ("IsTransitionIn", Int) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _T;//while transition,_T=0->1
            int _IsTransitionIn;

            //ここに遷移(入)を書く
            fixed4 TransitionIn(v2f i){
                float invt=(1.0-_T)*1.8;
                float3 w = float3(0.0,0.0,0.0);
                float3 col=w;
                col=(1-i.uv.x<invt/0.3?float3(1.0,0,1.0):col);
                col=(1-i.uv.x<invt/0.4-0.7?float3(0.0,0.0,1.0):col);
                col=(1-i.uv.x<invt/0.5-1.5?float3(1.0,1.0,0.0):col);
                col=(1-i.uv.x<invt/0.6-2.0?float3(1.0,1.0,1.0):col);
                fixed4 res=(1-i.uv.x<invt/0.3?float4(col,1.0):tex2D(_MainTex, i.uv));
                return res;
            }

            //ここに遷移(出)を書く
            fixed4 TransitionOut(v2f i){
                float invt=_T*1.8;
                float3 w = float3(0.0,0.0,0.0);
                float3 col=w;
                col=(i.uv.x<invt/0.3?float3(1.0,0,1.0):col);
                col=(i.uv.x<invt/0.4-0.7?float3(0.0,0.0,1.0):col);
                col=(i.uv.x<invt/0.5-1.5?float3(1.0,1.0,0.0):col);
                col=(i.uv.x<invt/0.6-2.0?float3(1.0,1.0,1.0):col);
                fixed4 res=(i.uv.x<invt/0.3?float4(col,1.0):tex2D(_MainTex, i.uv));
                return res;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                if(_IsTransitionIn==1){
                    return TransitionIn(i);
                    }else{
                    return TransitionOut(i);
                }
            }
            ENDCG
        }
    }
}

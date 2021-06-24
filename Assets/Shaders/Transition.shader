Shader "PostEffect/Transition"
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
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                float a=_T;
                float3 x=1 - col.rgb;
                float3 y=col.rgb;
                col.rgb = x*(1-a)+y*a ;
                return col;
            }

            //ここに遷移(出)を書く
            fixed4 TransitionOut(v2f i){
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                float a=_T;
                float3 x=col.rgb;
                float3 y=1 - col.rgb;
                col.rgb = x*(1-a)+y*a ;
                return col;
                
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

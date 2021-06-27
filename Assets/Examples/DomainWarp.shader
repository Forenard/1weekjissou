Shader "PostEffect/DomainWarp"
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
            
            //Height/Width
            float aspect(){
                float4 projectionSpaceUpperRight = float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y);
                float4 viewSpaceUpperRight = mul(unity_CameraInvProjection, projectionSpaceUpperRight);
                return viewSpaceUpperRight.y/viewSpaceUpperRight.x;
            }

            float mix(float x,float y,float a){
                return x*(1-a)+y*a;
            }

            float4 mix4(float4 x,float4 y,float a){
                return x*(1-a)+y*a;
            }

            float rand(float2 n) {
                return frac(sin(dot(n, float2(12.9898, 4.1414))) * 43758.5453);
            }

            float noise(float2 p) {
                float2 ip = floor(p);
                float2 u = frac(p);
                u = u*u*(3.0-2.0*u);

                float res = mix(
                mix(rand(ip),rand(ip+float2(1.0,0.0)),u.x),
                mix(rand(ip+float2(0.0,1.0)),rand(ip+float2(1.0,1.0)),u.x),u.y);
                return res*res;
            }

            const float2x2 m2 = float2x2(0.8,-0.6,0.6,0.8);

            float fbm( in float2 p ){
                float f = 0.0;
                f += 0.5000*noise( p ); p = mul(p,m2)*2.02;
                f += 0.2500*noise( p ); p = mul(p,m2)*2.03;
                f += 0.1250*noise( p ); p = mul(p,m2)*2.01;
                f += 0.0625*noise( p );

                return f/0.769;
            }

            float pattern( in float2 p ,float t) {
                float qfbm=fbm(p + float2(0.0,0.0));
                float2 q = float2(qfbm,qfbm);
                float rfbm=fbm( p + 4.0*q + float2(1.7,9.2));
                float2 r = float2(rfbm,rfbm);
                r+= float2(t * 0.15,t * 0.15);
                return fbm( p + 1.760*r );
            }

            //ここに遷移(入)を書く
            fixed4 TransitionIn(v2f i){
                float invt=_T*10.0;
                float2 xy=i.uv;
                xy.y*=aspect();
                xy *= 4.5;
                float displacement = pattern(xy,invt);
                float4 color = float4(displacement * 1.2, 0.2, displacement * 5., 1.);
                color.a = min(color.r * 0.25, 1.);
                return mix4(color,tex2D(_MainTex, i.uv),smoothstep(0.0,0.7,(_T)));
            }

            //ここに遷移(出)を書く
            fixed4 TransitionOut(v2f i){
                float invt=_T*10.0+10.0;
                float2 xy=i.uv;
                xy.y*=aspect();
                xy *= 4.5;
                float displacement = pattern(xy,invt);
                float4 color = float4(displacement * 1.2, 0.2, displacement * 5., 1.);
                color.a = min(color.r * 0.25, 1.);
                return mix4(color,tex2D(_MainTex, i.uv),smoothstep(0.0,0.7,(1-_T)));
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

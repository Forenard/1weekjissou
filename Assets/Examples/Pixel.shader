Shader "PostEffect/TransitionPixel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _T ("Time", Float) = 0.0
        [MaterialToggle] _IsTransitionIn ("IsTransitionIn", Int) = 1

        _Width("Width", Int) = 960
        _Height("Height",Int) = 540
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

            float _Width;
            float _Height;

            //ここに遷移(入)を書く
            fixed4 TransitionIn(v2f i){
                float invt=_T;
                invt=pow(invt,5);
                float w=floor(clamp(_Width*invt,1.0,_Width));
                float h=floor(clamp(_Height*invt,1.0,_Height));
                float2 grid;
                grid.x = floor(i.uv.x * w) / w;
                grid.y = floor(i.uv.y * h) / h;
                fixed4 col = tex2D(_MainTex, grid);
                return col;
            }

            //ここに遷移(出)を書く
            fixed4 TransitionOut(v2f i){
                float invt=1-_T;
                invt=pow(invt,5);
                float w=floor(clamp(_Width*invt,1.0,_Width));
                float h=floor(clamp(_Height*invt,1.0,_Height));
                float2 grid;
                grid.x = floor(i.uv.x * w) / w;
                grid.y = floor(i.uv.y * h) / h;
                fixed4 col = tex2D(_MainTex, grid);
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

//
// Example shader - block_world.fx
//
 
 
//---------------------------------------------------------------------
// Block world settings
//---------------------------------------------------------------------
texture nTexture;
float4 nColor = float4(1,1,1,1);
 
 
//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
 
 
//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture         = (nTexture);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
};
 
//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord: TEXCOORD0;
};
 
 
//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
 
    float2 uv = PS.TexCoord;
    float4 texel = tex2D(Sampler0, uv);
 
    float alpha = tex2D(Sampler0, PS.TexCoord).a;
 
    // Modulate texture with lighting and colorization value
    float4 finalColor = texel * PS.Diffuse * nColor;
    finalColor.a = alpha * PS.Diffuse.a;
 
    return finalColor;
}
 
 
//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique blocky
{
    pass P0
    {
        AlphaBlendEnable = TRUE;
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}
 
// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
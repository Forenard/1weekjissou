using UnityEngine;

[RequireComponent(typeof(Camera))]


[ExecuteInEditMode]
public class TransitionCameraFilter : MonoBehaviour
{
    [SerializeField] private Material filter;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, filter);
    }
}
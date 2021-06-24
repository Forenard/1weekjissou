using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;

[RequireComponent(typeof(Camera))]



[ExecuteInEditMode]
public class TransitionCameraFilter : MonoBehaviour
{
    [SerializeField] private List<Material> filters;
    [SerializeField] private AnimationCurve animationCurve = AnimationCurve.Linear(0, 0, 1, 1);

    [SerializeField] private float transitionTime = 1f;
    [SerializeField] private bool traInWhenSceneStart = true;
    [SerializeField] private bool camStopWhenTraIn = true;
    [SerializeField] private bool loadSceneWhenTraIn = true;
    [SerializeField] private string sceneName;

    private float elapsedTime = 0f;
    private RenderTexture cameraTexture = null;

    private bool useCameraTexture = false;
    ///<summary>
    ///StartTransition()を呼び出されると遷移を行う
    ///<summary>
    public void StartTransition(bool isTransitionIn = false)
    {
        StartCoroutine(TransitionControl(isTransitionIn));
    }

    private void Start()
    {
        if (traInWhenSceneStart) StartTransition(true);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!useCameraTexture && camStopWhenTraIn) cameraTexture = src;
        foreach (var filter in filters)
        {
            Graphics.Blit(cameraTexture, dest, filter);
        }
    }

    private void LoadScene()
    {
        SceneManager.LoadScene(sceneName);
    }


    private IEnumerator TransitionControl(bool isTransitionIn)
    {
        elapsedTime = 0f;
        if (isTransitionIn)
        {
            foreach (var filter in filters)
            {
                filter.SetInt("_IsTransitionIn", 1);
            }

        }
        else
        {
            useCameraTexture = true;
            foreach (var filter in filters)
            {
                filter.SetInt("_IsTransitionIn", 0);
            }
        }


        while (true)
        {
            if (elapsedTime >= transitionTime)
            {
                elapsedTime = transitionTime;
                foreach (var filter in filters)
                {
                    filter.SetFloat("_T", animationCurve.Evaluate(1f));
                }
                if (loadSceneWhenTraIn && !isTransitionIn) LoadScene();
                useCameraTexture = false;
                yield break;
            }
            foreach (var filter in filters)
            {
                filter.SetFloat("_T", animationCurve.Evaluate(elapsedTime / transitionTime));
            }

            elapsedTime += Time.deltaTime;
            yield return null;
        }
    }

    //forEditor-------------------------------------------------------
    private void Awake()
    {
        if (filters.Count == 0)
        {
            filters = new List<Material> { new Material(Shader.Find("Transition")) };
        }

        EditorApplication.playModeStateChanged += OnChangedPlayMode;
    }

    private void OnChangedPlayMode(PlayModeStateChange state)
    {
        if (state == PlayModeStateChange.EnteredEditMode)
        {
            foreach (var filter in filters)
            {
                filter.SetFloat("_T", 0f);
            }

        }
    }
}


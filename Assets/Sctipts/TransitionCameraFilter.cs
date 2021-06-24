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
    [SerializeField] private AnimationCurve animationCurve;

    [SerializeField] private float transitionTime;
    [SerializeField] private bool transitionInWhenSceneStart;
    [SerializeField] private bool isLoadScene;
    [SerializeField] private string sceneName;

    private float elapsedTime = 0f;
    private IEnumerator coroutine;


    ///<summary>
    ///StartTransition()を呼び出されると遷移を行う
    ///<summary>
    public void StartTransition(bool isTransitionIn = false)
    {
        StartCoroutine(TransitionControl(isTransitionIn));
    }

    private void Start()
    {
        if (transitionInWhenSceneStart) StartTransition(true);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        foreach (var filter in filters)
        {
            Graphics.Blit(src, dest, filter);
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
                if (isLoadScene && !isTransitionIn) LoadScene();
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


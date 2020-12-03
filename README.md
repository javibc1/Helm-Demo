# Helm, Operators, Tekton & ArgoCD DEMO

## Helm
In [demo-chart](demo-chart/) there's a chart deploying a custom simple application (src of the simple web app can be found in [simple-js](simple-js/)).
You can see the manifests that the chart creates without installing them by running `helm install --dry-run --debug ./demo-chart --genereate-name`
To install the chart `helm install ./demo-chart --genereate-name`

## Operators
Operators can be installed with the OpenShift console, but you can install most of them with a simple subscription object. Examples can be found in servicemesh for [kiali](servicemesh/kiali-op.yaml), [jaeger](servicemesh/jaeger-op.yaml) and [servicemesh](sm-op.yaml) operators. An example of installing Kiali would be `oc apply -f servicemesh/kiali-op.yaml`

## Tekton
You can find an example of a Tekton pipeline in [tekton/example](tekton/example/).
 > For sharing objects between tasks a [pvc](tekton/mypipe/pvc.yaml) must be associated with the workspace in the PipelineRun.

2 custom pipelines have been done in [tekton/mypipe](tekton/mypipe/)
- [Build-Pipe](tetkon/mypipe/build-pipe.yaml) builds the image and pushes to the quay registry, it has 3 tasks:
  1. Fetches the repository
  2. Custom tasks added for debugging (checks the files in the shared workspace)
  3. Build the image and push to registry
- [Manifest-Pipe](tekton/mypipe/manifest-pipe.yaml) modifies some files with custom values and pushes the new files to the repository, it has 2 tasks:
  1. Fetches the repository
  2. Changes the manifests (with a simple sed command) and pushes it to the registry
- A [webhook](tekton/mypipe/trigger.yaml) has been done for Build-Pipe creating the following objects:
  - TriggerBinding: associates values to the params for instantiation of the pipeline
  - TriggerTemplate: is a PipelineRun associated to our build-pipe
  - EventListener: exposes a service for your git webhook, must be exposed to the internet, e.g. in OpenShift: `oc expose svc el-simple-js` 
> For pushing the image to your registry, or the new code to your repository, you need to create a secret with your credentials, and list them in the pipeline serviceaccount of the namespace in which you want your pipeline to run. This step can also be done in the console when creating a new PipelineRun from your Pipeline.

## ArgoCD
After installing the ArgoCD operator, a new ArgoCD instance can be deployed by running `oc apply -f argo.yaml`.
The default user is admin, and you can find the password by executing the command 
```oc get secret argocd-cluster -n argocd -ojsonpath='{.data.admin\.password}' | base64 --decode```
You can now deploy some apps in the ArgoCD console by synchronizing [recommendation](recommendation/), [bookinfo](bookinfo/) or [my-example](tekton/mypipe/deploy/) which has been pushed to the repository by the previous tekton pipeline.

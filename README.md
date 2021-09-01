# Helm Kubeconform Github Action

A [GitHub Action](https://github.com/features/actions) for using [Kubeconform](https://github.com/yannh/kubeconform) to validate Helm Charts in your workflows.

Supports Helm 3 only.

## Example Workflow

You can use the action as follows:

```yaml
on: push
name: Helm / Validate
jobs:
  kubeval:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: test
      uses: nlamirault/helm-kubeval-action@v0.1.0
      with:
        path: ./charts
```

For each chart:

- look for values file in its ci directory
- run `helm template` and validate the output as Kubernetes objects.

## Inputs

For more information on inputs, see the [API Documentation](https://developer.github.com/v3/repos/releases/#input)

| Property | Default | Description |
| --- | --- | --- |
| path | . | The path to the directory containing your Chart(s) |

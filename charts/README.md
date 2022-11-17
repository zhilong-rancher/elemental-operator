# elemental-operator

[elemental-operator](https://github.com/rancher/elemental-operator) The Elemental operator is responsible for managing the Elemental versions and maintaining a machine inventory to assist with edge or baremetal installations.

This chart bootstraps an elemental-operator deployment on the [Rancher Manager v2.6](https://rancher.com/docs/rancher/v2.6/) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Rancher Manager version v2.6
- Helm client version v3.8.0+

## Get Helm chart info

```console
helm pull oci://registry.opensuse.org/isv/rancher/elemental/charts/elemental/elemental-operator
helm show all oci://registry.opensuse.org/isv/rancher/elemental/charts/elemental/elemental-operator
```

## Install Chart

```console
helm install --create-namespace -n cattle-elemental-system elemental-operator \
             oci://registry.opensuse.org/isv/rancher/elemental/charts/elemental/elemental-operator
```

The command deploys elemental-operator on the Kubernetes cluster in the default configuration.

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall -n cattle-elemental-system elemental-operator
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade -n cattle-elemental-system \
             --install elemental-operator \
             oci://registry.opensuse.org/isv/rancher/elemental/charts/elemental/elemental-operator
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values oci://registry.opensuse.org/isv/rancher/elemental/charts/elemental/elemental-operator
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.empty | string | `rancher/pause:3.1` |  |
| image.repository | string | `quay.io/costoolkit/elemental-operator` | Source image for elemental-operator with repository name  |
| image.tag | tag | `""` |  |
| image.imagePullPolicy | string | `IfNotPresent` |  |
| noProxy | string | `127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.svc,.cluster.local" | Comma separated list of domains or ip addresses that will not use the proxy |
| global.cattle.systemDefaultRegistry | string | `""` | Default container registry name  |
| sync_interval | string | `"60m"` | Default sync interval for upgrade channel |
| sync_namespaces | list | `[]` | Namespace the operator will watch for, leave empty for all |
| debug | bool | `false` | Enable debug output for operator |
| nodeSelector.kubernetes.io/os | string | `linux` |  |
| tolerations | object | `{}` |  |
| tolerations.key | string | `cattle.io/os` |  |
| tolerations.operator | string | `"Equal"` |  |
| tolerations.value | string | `"linux"` |  |
| tolerations.effect | string | `NoSchedule` |  |


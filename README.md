# Teranode Operator Helm Chart

[Helm](https://helm.sh/docs/) chart for deploying the [Teranode Operator](https://github.com/bsv-blockchain/teranode-operator) on [Kubernetes](https://kubernetes.io/docs/home/).

The Teranode Operator manages [Teranode](https://www.bsvblockchain.org/teranode) blockchain node deployments on Kubernetes using Custom Resource Definitions (CRDs).

## Installation

### Prerequisites

**Install CRDs first** (required before installing the operator):

```bash
# Install CRDs from the operator repository (v0.1.2)
kubectl apply --server-side -f https://raw.githubusercontent.com/bsv-blockchain/teranode-operator/v0.1.2/deploy/crds.yaml
```

**Important:**
- CRDs must be installed separately because they exceed the **Kubernetes Secret size limit of 1MB** (Helm stores release metadata in Secrets, and the CRDs are ~3.6MB)
- The `--server-side` flag is required because some CRDs exceed the 256KB annotation size limit
- CRDs are versioned with the operator and should match the `appVersion` in the chart

### From OCI Registry (Recommended)

```bash
helm install teranode-operator oci://ghcr.io/bsv-blockchain/helm/teranode-operator \
  -n teranode-operator \
  --create-namespace \
  --set deployment.env.watch_namespace="teranode"
```

### From Source

```bash
# Install CRDs first
kubectl apply --server-side -f https://raw.githubusercontent.com/bsv-blockchain/teranode-operator/v0.1.2/deploy/crds.yaml

# Clone and install chart
git clone https://github.com/bsv-blockchain/teranode-operator-helm.git
cd teranode-operator-helm
helm install teranode-operator ./ \
  -n teranode-operator \
  --create-namespace \
  --set deployment.env.watch_namespace="teranode"
```

## Configuration

### Key Values

| Parameter                        | Description                                       | Default                                    |
|----------------------------------|---------------------------------------------------|--------------------------------------------|
| `deployment.image.repository`    | Operator container image repository               | `ghcr.io/bsv-blockchain/teranode-operator` |
| `deployment.image.tag`           | Operator container image tag                      | `v0.1.2`                                   |
| `deployment.image.pullPolicy`    | Image pull policy                                 | `Always`                                   |
| `deployment.env.watch_namespace` | Comma-separated list of namespaces to watch       | `""`                                       |
| `deployment.replicaCount`        | Number of operator replicas                       | `1`                                        |
| `sampleCluster.enable`           | Deploy a sample Teranode cluster                  | `false`                                    |
| `sampleCluster.network`          | Network type for sample cluster (mainnet/testnet) | `testnet`                                  |
| `sampleCluster.hostname`         | Hostname for sample cluster                       | `""`                                       |

### Example: Multiple Namespaces

```bash
helm install teranode-operator ./ \
  -n teranode-operator \
  --create-namespace \
  --set deployment.env.watch_namespace="teranode-dev,teranode-staging,teranode-prod"
```

### Example: Sample Cluster

Deploy a sample Teranode cluster along with the operator:

```bash
helm install teranode-operator ./ \
  -n teranode-operator \
  --create-namespace \
  --set deployment.env.watch_namespace="teranode" \
  --set sampleCluster.enable=true \
  --set sampleCluster.hostname=example.com \
  --set sampleCluster.network=mainnet
```

**Note:** The sample cluster is opinionated and requires the BSVA reference architecture deployed via Terraform/OpenTofu modules.

## Upgrading

When upgrading to a new operator version, update the CRDs first:

```bash
# Update CRDs to match new operator version (e.g., v0.1.3)
kubectl apply --server-side -f https://raw.githubusercontent.com/bsv-blockchain/teranode-operator/v0.1.3/deploy/crds.yaml

# Upgrade the Helm chart
helm upgrade teranode-operator oci://ghcr.io/bsv-blockchain/helm/teranode-operator \
  --version 0.1.1 \
  -n teranode-operator
```

## Uninstallation

```bash
# Uninstall the operator
helm uninstall teranode-operator -n teranode-operator

# Optionally remove CRDs (WARNING: This deletes all Teranode resources)
kubectl get crd -o name | grep '\.teranode\.bsvblockchain\.org' | xargs kubectl delete
```

**Warning:** Deleting CRDs will remove all Teranode custom resources in your cluster.

## Development

### Testing Locally

```bash
# Lint the chart
helm lint .

# Dry-run installation
helm install teranode-operator ./ \
  --dry-run \
  --debug \
  -n teranode-operator \
  --set deployment.env.watch_namespace="teranode"

# Template rendering
helm template teranode-operator ./ \
  --namespace teranode-operator \
  --set deployment.env.watch_namespace="teranode"
```

## Versioning

This chart follows semantic versioning **independent** from the operator:

- **Chart Version** (`version` in Chart.yaml): Version of the Helm chart packaging
  - Bump MAJOR for breaking changes to chart structure/values
  - Bump MINOR for new features (new values, templates)
  - Bump PATCH for bug fixes and documentation updates

- **App Version** (`appVersion` in Chart.yaml): Teranode Operator version being deployed
  - Should match a released operator version tag (e.g., `0.1.2` for operator tag `v0.1.2`)
  - Update `values.yaml` `deployment.image.tag` to match (with `v` prefix: `v0.1.2`)
  - **Important:** Also update the CRD installation URL in the README to match the new version

**Example**: Chart version `0.2.5` might deploy operator version `0.1.2` if only chart changes were made.

See [Chart.yaml](./Chart.yaml) for current versions.

## Requirements

| Name       | Version |
|------------|---------|
| Helm       | >= 3.15 |
| Kubernetes | >= 1.30 |

## Release History

| Chart Version | App Version | Date       | Changes                |
|---------------|-------------|------------|------------------------|
| 0.1.1         | 0.1.2       | 12/11/2025 | Remove CRDs from chart |
| 0.1.0         | 0.1.2       | 12/11/2025 | Initial release        |

## Contributing

1. Make changes to the chart templates/values
2. Update `Chart.yaml`:
   - Bump `version` for chart changes
   - Update `appVersion` if deploying a new operator version
3. If operator version changed:
   - Update `values.yaml` `deployment.image.tag`
   - Update CRD installation URL in README (Prerequisites section)
4. Test locally: `helm lint . && helm template . --debug`
5. Commit and push to `main` branch
6. GitHub Actions will automatically publish to GHCR

## License

See [LICENSE](./LICENSE) for details.

## Support

For issues and questions:
- **Operator Issues**: https://github.com/bsv-blockchain/teranode-operator/issues
- **Chart Issues**: https://github.com/bsv-blockchain/teranode-operator-helm/issues
- **Documentation**: https://docs.bsvblockchain.org/

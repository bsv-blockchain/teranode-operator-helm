# Teranode Operator Helm Chart

[Helm](https://helm.sh/docs/) chart for deploying the [Teranode Operator](https://github.com/bsv-blockchain/teranode-operator) on [Kubernetes](https://kubernetes.io/docs/home/).

The Teranode Operator manages [Teranode](https://www.bsvblockchain.org/teranode) blockchain node deployments on Kubernetes using Custom Resource Definitions (CRDs).

## Installation

### From OCI Registry (Recommended)

```bash
helm install teranode-operator oci://ghcr.io/bsv-blockchain/helm/teranode-operator \
  --version 0.1.0 \
  -n teranode-operator \
  --create-namespace \
  --set deployment.env.watch_namespace="teranode"
```

### From Source

```bash
git clone https://github.com/bsv-blockchain/teranode-operator-helm.git
cd teranode-operator-helm
git submodule update --init --recursive
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

## Uninstallation

```bash
helm uninstall teranode-operator -n teranode-operator
```

### Complete Cleanup (Including CRDs)

Helm does not automatically remove CRDs during uninstallation. To completely remove all operator resources:

```bash
# Uninstall the operator
helm uninstall teranode-operator -n teranode-operator

# Remove all CRDs
kubectl get crd -o name | grep '\.teranode\.bsvblockchain\.org' | xargs kubectl delete
```

**Warning:** This will delete all Teranode custom resources in your cluster.

## Development

This repository uses a git submodule to track the operator source code for CRD synchronization.

### Initial Setup

```bash
git clone https://github.com/bsv-blockchain/teranode-operator-helm.git
cd teranode-operator-helm
git submodule update --init --recursive
```

### Updating CRDs for a New Operator Version

When a new operator version is released, sync the CRDs:

```bash
# Option 1: Specify version explicitly
./sync-crds.sh v0.1.3

# Option 2: Update Chart.yaml appVersion first, then run without args
# Edit Chart.yaml: appVersion: "0.1.3"
./sync-crds.sh  # Uses appVersion from Chart.yaml

# Commit the updated CRDs and submodule reference
git add crds/ operator Chart.yaml values.yaml
git commit -m "Update to operator v0.1.3"
```

**Important**: The `operator/` submodule always points to a specific version tag (e.g., `v0.1.2`), not a branch. This ensures the chart is always tested against a known operator version.

### Manual CRD Sync

If you prefer manual synchronization:

```bash
# Checkout specific operator version
cd operator && git fetch --tags && git checkout v0.1.3 && cd ..

# Copy CRDs
cp operator/deploy/crds.yaml crds/crds.yaml

# Stage the submodule reference
git add operator crds/
```

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
  - The `operator/` submodule is pinned to this exact version tag
  - Update `values.yaml` `deployment.image.tag` to match (with `v` prefix: `v0.1.2`)

**Example**: Chart version `0.2.5` might deploy operator version `0.1.2` if no operator updates were needed.

See [Chart.yaml](./Chart.yaml) for current versions.

## Requirements

| Name       | Version |
|------------|---------|
| Helm       | >= 3.15 |
| Kubernetes | >= 1.30 |

## Release History

| Chart Version | App Version | Date       | Changes         |
|---------------|-------------|------------|-----------------|
| 0.1.0         | 0.1.0       | 12/11/2025 | Initial release |

## Contributing

1. Make changes to the chart
2. Update `Chart.yaml` version (bump chart version for chart changes, appVersion for operator updates)
3. Update CRDs if operator version changed: `./sync-crds.sh`
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

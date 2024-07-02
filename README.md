# KinD Kubernetes Cluster Automation

This project automates the setup of a multi-node Kubernetes cluster using KinD (Kubernetes in Docker), along with the deployment of NGINX Ingress Controller, Prometheus monitoring, and sample applications. It provides a simple CLI interface to manage the entire lifecycle of the cluster and its components.

## Prerequisites

- Latest Docker installation
- Terminal access with necessary permissions
- Git

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/nithinM/kind-k8s-cluster-automation.git
   cd kind-k8s-cluster-automation
   ```

2. Ensure the `cli` script is executable:
   ```bash
   chmod +x cli
   ```

## Usage

The project provides a CLI tool that simplifies the management of the Kubernetes cluster and its components. Here are the main commands:

- **Setup the cluster and deploy all components**:
  ```bash
  ./cli setup
  ```
  This command initializes the Kubernetes cluster, deploys NGINX Ingress Controller, Prometheus, and sample applications.

- **Generate metrics report**:
  ```bash
  ./cli generate-metrics-report
  ```
  This command generates time-series data using PromQL queries.

- **Run benchmarks**:
  ```bash
  ./cli benchmark [scenario]
  ```
  This command runs performance benchmarks for the specified scenario. Available scenarios:
    - `Test foo endpoint`
    - `Test foo and bar endpoints sequentially`
      If no scenario is specified, the default is to test all scenarios.

- **Cleanup the entire setup**:
  ```bash
  ./cli cleanup
  ```
  This command removes all deployed components and the Kubernetes cluster.

- **Access the Docker container**:
  ```bash
  ./cli access
  ```
  Provides access to the Docker container for troubleshooting and management.

- **Run Docker commands**:
  ```bash
  ./cli docker <docker-command>
  ```

- **Run Terraform commands**:
  ```bash
  ./cli terraform <terraform-command>
  ```

- **Run KinD commands**:
  ```bash
  ./cli kind <kind-command>
  ```

- **Run kubectl commands**:
  ```bash
  ./cli kubectl <kubectl-command>
  ```

## Configuration

All configurations can be customized through environment variables or by modifying the `.env` file in the repository. The default configuration is provided in the `.env` file.

Example `.env` file:
```env
TERRAFORM_VERSION=1.0.0
KIND_VERSION=0.11.1
KUBECTL_VERSION=1.21.0
HELM_VERSION=3.5.4
PROMETHEUS_QUERY_DURATION=5m
PROMETHEUS_QUERY_STEP=15s
BENCHMARK_CONCURRENCY=10
BENCHMARK_DURATION=30s
```

## Output

- **./cli setup**: Displays the health status of all deployed services.
- **./cli generate-metrics-report**: Generates time-series data using PromQL queries in the `/workspace/report/metrics` directory.
- **./cli benchmark**: Produces benchmark reports in the `/workspace/report/benchmarking` directory.

## Project Structure

```plaintext
.
├── Dockerfile
├── LICENSE
├── README.md
├── cli
├── k8s-manifests/
│   ├── deploy_manifests
│   ├── ingress/
│   ├── monitor/
│   ├── namespaces/
│   └── services/
├── report/
│   ├── benchmarking/
│   └── metrics/
├── terraform/
│   ├── main.tf
│   ├── modules/
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── versions.tf
└── util/
    ├── common-functions
    ├── metrics_script
    └── run_benchmarks
```

## KinD-specific Ingress NGINX Configuration

The NGINX Ingress Controller configuration has been modified to enable metrics scraping by Prometheus. Key changes include:

- Service annotations for Prometheus scraping
- Metrics enabled in the Deployment
- New port added for metrics in the Service
- Metrics container port added in the Deployment

These configurations ensure that Prometheus can scrape metrics from the NGINX Ingress Controller, providing valuable insights into its performance and health.

## Troubleshooting

If you encounter timeout errors during `./cli setup`, try running the script again. Timeouts may occur due to varying machine performance.

For common issues:
- Ensure Docker is running.
- Verify network connectivity.
- Check for permission issues with the CLI script.

## Known Limitations

The Prometheus web UI is not accessible from the host machine in the current implementation.

## Additional Features

This project leverages various tools and technologies to provide a fully automated and customizable Kubernetes environment:

- **Docker**: Containerization platform.
- **Terraform**: Infrastructure as code tool.
- **Shell scripts**: Automation scripts.
- **Helm**: Kubernetes package manager.
- **Artillery**: Performance testing tool (for benchmarking).

## Cleanup

To remove the entire setup and clean up resources, run:
```bash
./cli cleanup
```
This command will destroy Terraform resources, stop and remove the Docker container, and remove the Docker image.

## References

- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [KinD Documentation](https://kind.sigs.k8s.io/)
- [GitHub Copilot](https://github.com/features/copilot)
- [ChatGPT](https://openai.com/chatgpt)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.


## Support

If you encounter any issues or have questions, please file an issue on the GitHub repository.

# Use an official Docker image as the base
FROM docker:latest

# Set default versions for Terraform, KinD, and kubectl
ARG TERRAFORM_VERSION="1.8.5"
ARG KIND_VERSION="v0.23.0"
ARG KUBECTL_VERSION="latest"

# Print the target platform for debugging purposes
ARG TARGETPLATFORM
RUN echo "Building for platform: $TARGETPLATFORM"

# Install necessary dependencies
RUN apk add --no-cache \
    curl \
    bash \
    git \
    openrc \
    python3 \
    py3-pip

# Install KinD
RUN ARCH=$(echo $TARGETPLATFORM | cut -d'/' -f2) && \
    echo "Determined architecture: $ARCH" && \
    if [ "$ARCH" = "amd64" ]; then \
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64; \
    elif [ "$ARCH" = "arm64" ]; then \
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-arm64; \
    else \
        echo "Unsupported architecture"; exit 1; \
    fi && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

# Install Terraform
RUN ARCH=$(echo $TARGETPLATFORM | cut -d'/' -f2) && \
    echo "Determined architecture: $ARCH" && \
    if [ "$ARCH" = "amd64" ]; then \
        curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip; \
    elif [ "$ARCH" = "arm64" ]; then \
        curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip -o terraform.zip; \
    else \
        echo "Unsupported architecture"; exit 1; \
    fi && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    rm terraform.zip

# Install kubectl
RUN if [ "$KUBECTL_VERSION" = "latest" ]; then \
        KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt); \
    fi && \
    ARCH=$(echo $TARGETPLATFORM | cut -d'/' -f2) && \
    echo "KUBECTL_VERSION is set to $KUBECTL_VERSION" && \
    echo "TARGETPLATFORM version $TARGETPLATFORM" && \
    echo "Architecture is set to $ARCH" && \
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$ARCH/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
FROM chainguard/wolfi-base:latest@sha256:1c56f3ceb1c9929611a1cc7ab7a5fde1ec5df87add282029cd1596b8eae5af67

# Install dependencies
# Keep alphabetized please
RUN apk add --no-cache \
    aws-cli-v2=2.22.13-r0 \
    bash=5.2.37-r30 \
    coreutils=9.6-r30 \
    curl=8.12.1-r0 \
    git=2.49.0-r0 \
    gitleaks=8.24.2-r0 \
    glab=1.55.0-r0 \
    gpg=2.2.41-r5 \
    gpg-agent=2.2.41-r5 \
    grype=0.91.0-r0 \
    helm=3.17.2-r0 \
    jq=1.7.1-r2 \
    kubectl-1.32-default=1.32.3-r3 \
    maru=0.6.0-r0 \
    nodejs=23.10.0-r0 \
    npm=11.2.0-r0 \
    openssl=3.4.1-r2 \
    oras=1.2.2-r3 \
    pinentry=1.3.1-r0 \
    trivy=0.61.0-r0 \
    yamllint=1.37.0-r0 \
    zarf=0.50.0-r1

# Configure DoD PKI certificates
RUN curl -o dod_ca.zip https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/unclass-certificates_pkcs7_DoD.zip && \
    unzip -j dod_ca.zip -d /tmp/dod_ca && \
    openssl pkcs7 -in /tmp/dod_ca/Certificates_PKCS7_v5_14_DoD.der.p7b -inform der -print_certs -out /tmp/dod_ca.crt && \
    cat /tmp/dod_ca.crt >> /etc/ssl/certs/ca-certificates.crt && \
    rm -rf /tmp/*

# Install hadolint
RUN curl -L https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 --output /usr/bin/hadolint && \
    chmod +x /usr/bin/hadolint

# Install UDS CLI
RUN curl -L https://github.com/defenseunicorns/uds-cli/releases/download/v0.25.0/uds-cli_v0.25.0_Linux_amd64 --output /usr/bin/uds && \
    chmod +x /usr/bin/uds

# Install shellcheck
RUN curl -L https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz --output /tmp/shellcheck.tar.xz && \
    mkdir -p /tmp/shellcheck && \
    tar -xJf /tmp/shellcheck.tar.xz -C /tmp/shellcheck && \
    mv /tmp/shellcheck/shellcheck-v0.10.0/shellcheck /usr/bin/ && \
    rm -rf /tmp/*

# Install releae-it plugins
RUN npm install -g release-it@19.2.4 \
    && npm install -g @j-ulrich/release-it-regex-bumper@5.2.0 \
    && npm install -g @release-it/conventional-changelog@10.0.0

# Install the Trivy Zarf Plugin
RUN trivy plugin update && trivy plugin install zarf@v0.4.1
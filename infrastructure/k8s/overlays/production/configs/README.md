# TLS Configuration with Azure Application Gateway and Let's Encrypt

This directory contains the TLS/SSL configuration for the application using Azure Application Gateway, cert-manager, and Let's Encrypt.

## Components

### Certificate (frontend-certificate.yaml)
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: archiverse-studioq-tls
  namespace: archiverse
spec:
  secretName: archiverse-studioq-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - archiverse.studioq.biz
```

This Certificate resource:
- Uses cert-manager to automatically obtain and renew TLS certificates from Let's Encrypt
- Stores the certificate in a Kubernetes secret named `archiverse-studioq-tls`
- Issues the certificate for the domain `archiverse.studioq.biz`

### Ingress (frontend-ingress.yaml)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    appgw.ingress.kubernetes.io/backend-protocol: "https"
    appgw.ingress.kubernetes.io/backend-hostname: "archiverse.studioq.biz"
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: azure-application-gateway
  tls:
  - hosts:
    - archiverse.studioq.biz
    secretName: archiverse-studioq-tls
```

The Ingress configuration:
- Uses Azure Application Gateway as the ingress controller
- Enables end-to-end TLS encryption
- Uses the Let's Encrypt certificate stored in `archiverse-studioq-tls` secret
- Forces SSL redirect for all traffic

## How it Works

1. **Certificate Generation**:
   - cert-manager watches for Certificate resources
   - When it finds our certificate request, it:
     1. Generates a new certificate signing request (CSR)
     2. Validates domain ownership with Let's Encrypt
     3. Obtains the certificate
     4. Stores it in the specified Kubernetes secret

2. **TLS Termination**:
   - Azure Application Gateway reads the TLS configuration from the Ingress
   - It uses the certificate from the Kubernetes secret for TLS termination
   - Backend communication is also encrypted (end-to-end TLS)

3. **Certificate Renewal**:
   - cert-manager automatically renews certificates before expiry
   - The renewal process is transparent to the application
   - No manual intervention required

## Troubleshooting

If Application Gateway reports it can't find a pre-installed SSL certificate:

1. Verify the Certificate resource is Ready:
   ```bash
   kubectl get certificate -n archiverse
   ```

2. Check the TLS secret exists:
   ```bash
   kubectl get secret archiverse-studioq-tls -n archiverse
   ```

3. Verify cert-manager logs:
   ```bash
   kubectl logs -n cert-manager -l app=cert-manager
   ```

4. Check Application Gateway Ingress Controller logs:
   ```bash
   kubectl logs -n kube-system -l app=ingress-appgw
   ```

## Important Notes

- The backend-protocol is set to "https" to enable end-to-end TLS encryption
- The backend-hostname annotation ensures proper SSL certificate validation
- SSL redirect is enabled to force all traffic over HTTPS
- cert-manager handles automatic certificate renewal

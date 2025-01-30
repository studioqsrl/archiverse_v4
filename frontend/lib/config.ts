interface PublicConfig {
  auth0Domain: string;
  customClaimsNamespace: string;
  environment: string;
}

interface PrivateConfig {
  auth0ClientSecret: string;
  auth0ManagementClientSecret: string;
  sessionEncryptionSecret: string;
}

// Public configuration that can be exposed to the client
export const publicConfig: PublicConfig = {
  auth0Domain: process.env.NEXT_PUBLIC_AUTH0_DOMAIN!,
  customClaimsNamespace: process.env.NEXT_PUBLIC_CUSTOM_CLAIMS_NAMESPACE!,
  environment: process.env.NODE_ENV,
};

// Private configuration only used server-side
export const getPrivateConfig = (): PrivateConfig => {
  // Ensure these are only accessed server-side
  if (typeof window !== 'undefined') {
    throw new Error('Private config can only be accessed server-side');
  }

  return {
    auth0ClientSecret: process.env.AUTH0_CLIENT_SECRET!,
    auth0ManagementClientSecret: process.env.AUTH0_MANAGEMENT_CLIENT_SECRET!,
    sessionEncryptionSecret: process.env.SESSION_ENCRYPTION_SECRET!,
  };
};

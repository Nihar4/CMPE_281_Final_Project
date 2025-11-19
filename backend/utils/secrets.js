import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

const client = new SecretsManagerClient({
  region: process.env.AWS_REGION || "us-east-1"
});

export const getSecret = async (secretName) => {
  try {
    const response = await client.send(
      new GetSecretValueCommand({
        SecretId: secretName,
        VersionStage: "AWSCURRENT", // VersionStage defaults to AWSCURRENT if unspecified
      })
    );
    
    if (response.SecretString) {
      return response.SecretString;
    }
    
    // For binary secrets (not used here but good practice)
    if (response.SecretBinary) {
      return response.SecretBinary.toString('utf-8');
    }
    
    return null;
  } catch (error) {
    console.error(`Error retrieving secret ${secretName}:`, error);
    // Fallback to env var if secret fetch fails (useful for local dev without AWS creds)
    // But for this assignment, we want to demonstrate fetching.
    // We can return null or throw.
    // If we are in local dev (NODE_ENV=development), we might want to skip this or handle gracefully.
    if (process.env.NODE_ENV === 'development') {
        console.log("Local development: ignoring secret fetch failure.");
        return null;
    }
    throw error;
  }
};

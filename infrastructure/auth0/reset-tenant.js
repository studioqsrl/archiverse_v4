import axios from 'axios';

const domain = 'studioq.eu.auth0.com';
const clientId = 'bDyAxchTD3vftuB1EQ5aETrJSk0NzeaD';
const clientSecret = 'syK7I_0DTUTAamnPEx7JG5aNBxmx6xuCwLs4Jm85hCGxtKwP3pXYXe-_nCtzltRN';

async function getManagementToken() {
  const response = await axios.post(`https://${domain}/oauth/token`, {
    client_id: clientId,
    client_secret: clientSecret,
    audience: `https://${domain}/api/v2/`,
    grant_type: 'client_credentials'
  });
  return response.data.access_token;
}

async function resetTenant() {
  try {
    const token = await getManagementToken();
    const api = axios.create({
      baseURL: `https://${domain}/api/v2`,
      headers: { Authorization: `Bearer ${token}` }
    });

    // Delete all clients except the management client
    const clients = await api.get('/clients');
    for (const client of clients.data) {
      if (client.client_id !== clientId) {
        await api.delete(`/clients/${client.client_id}`);
      }
    }

    // Delete all connections
    const connections = await api.get('/connections');
    for (const conn of connections.data) {
      await api.delete(`/connections/${conn.id}`);
    }

    // Delete all roles
    const roles = await api.get('/roles');
    for (const role of roles.data) {
      await api.delete(`/roles/${role.id}`);
    }

    // Delete all actions
    const actions = await api.get('/actions/actions');
    for (const action of actions.data.actions) {
      await api.delete(`/actions/actions/${action.id}`);
    }

    console.log('Tenant reset complete');
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

resetTenant();

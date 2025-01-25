import { $ } from "execa"
import ora from "ora"

async function deleteResources() {
  const spinner = ora('Deleting Auth0 resources').start()

  try {
    // Get all resources
    const { stdout: clientsJson } = await $`auth0 api get /clients`
    const clients = JSON.parse(clientsJson)
    
    const { stdout: connectionsJson } = await $`auth0 api get /connections`
    const connections = JSON.parse(connectionsJson)
    
    const { stdout: rolesJson } = await $`auth0 api get /roles`
    const roles = JSON.parse(rolesJson)
    
    const { stdout: actionsJson } = await $`auth0 api get /actions/actions`
    const actions = JSON.parse(actionsJson)

    // Delete clients (except the default "All Applications")
    spinner.text = 'Deleting clients'
    for (const client of clients) {
      if (!client.global) {
        await $`auth0 api delete /clients/${client.client_id}`
      }
    }

    // Delete connections
    spinner.text = 'Deleting connections'
    for (const connection of connections) {
      await $`auth0 api delete /connections/${connection.id}`
    }

    // Delete roles
    spinner.text = 'Deleting roles'
    for (const role of roles) {
      await $`auth0 api delete /roles/${role.id}`
    }

    // Delete actions (first remove bindings)
    if (actions.actions && actions.actions.length > 0) {
      spinner.text = 'Removing action bindings'
      await $`auth0 api patch /actions/triggers/post-login/bindings --data '{"bindings":[]}'`
      
      spinner.text = 'Deleting actions'
      for (const action of actions.actions) {
        await $`auth0 api delete /actions/actions/${action.id}`
      }
    }

    // Delete client grants
    spinner.text = 'Deleting client grants'
    const { stdout: grantsJson } = await $`auth0 api get /client-grants`
    const grants = JSON.parse(grantsJson)
    for (const grant of grants) {
      await $`auth0 api delete /client-grants/${grant.id}`
    }

    spinner.succeed('Auth0 resources deleted successfully')
  } catch (error) {
    spinner.fail(`Failed to delete Auth0 resources: ${error.message}`)
    if (error.stderr) {
      console.error('Error details:', error.stderr)
    }
    process.exit(1)
  }
}

deleteResources()

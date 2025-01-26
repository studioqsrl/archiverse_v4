#!/usr/bin/env python3
import json
import subprocess
import sys

def run_command(args):
    try:
        result = subprocess.run(args, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {' '.join(args)}")
        print(f"Error details:\n{e.stderr}")
        sys.exit(1)

def delete_resources():
    print("🔄 Deleting Auth0 resources...")

    # Get all resources
    print("📝 Fetching clients...")
    clients_json = run_command(["auth0", "api", "get", "/clients"])
    clients = json.loads(clients_json)

    print("📝 Fetching connections...")
    connections_json = run_command(["auth0", "api", "get", "/connections"])
    connections = json.loads(connections_json)

    print("📝 Fetching roles...")
    roles_json = run_command(["auth0", "api", "get", "/roles"])
    roles = json.loads(roles_json)

    print("📝 Fetching actions...")
    actions_json = run_command(["auth0", "api", "get", "/actions/actions"])
    actions = json.loads(actions_json)

    # Delete clients (except the default "All Applications")
    print("🗑️  Deleting clients...")
    for client in clients:
        if not client.get("global"):
            run_command(["auth0", "api", "delete", f"/clients/{client['client_id']}"])

    # Delete connections
    print("🗑️  Deleting connections...")
    for connection in connections:
        run_command(["auth0", "api", "delete", f"/connections/{connection['id']}"])

    # Delete roles
    print("🗑️  Deleting roles...")
    for role in roles:
        run_command(["auth0", "api", "delete", f"/roles/{role['id']}"])

    # Delete actions (first remove bindings)
    print("🗑️  Removing action bindings...")
    empty_bindings = json.dumps({"bindings": []})
    run_command(["auth0", "api", "patch", "/actions/triggers/post-login/bindings", "--data", empty_bindings])

    if actions.get("actions"):
        print("🗑️  Deleting actions...")
        for action in actions["actions"]:
            run_command(["auth0", "api", "delete", f"/actions/actions/{action['id']}"])

    # Delete client grants
    print("📝 Fetching client grants...")
    grants_json = run_command(["auth0", "api", "get", "/client-grants"])
    grants = json.loads(grants_json)

    print("🗑️  Deleting client grants...")
    for grant in grants:
        run_command(["auth0", "api", "delete", f"/client-grants/{grant['id']}"])

    # Delete branding theme
    print("🗑️  Deleting branding themes...")
    try:
        themes_json = run_command(["auth0", "api", "get", "/branding/themes"])
        themes = json.loads(themes_json)
        if isinstance(themes, list):
            for theme in themes:
                if isinstance(theme, dict) and not theme.get("isDefault"):
                    run_command(["auth0", "api", "delete", f"/branding/themes/{theme['themeId']}"])
        elif isinstance(themes, dict):
            # If there's only one theme
            if not themes.get("isDefault"):
                run_command(["auth0", "api", "delete", f"/branding/themes/{themes['themeId']}"])
    except Exception as e:
        print(f"Warning: Error while deleting themes: {str(e)}")

    # Reset email templates to defaults
    print("🔄 Resetting email templates...")
    templates = ["verify_email"]  # Add other templates if needed
    for template in templates:
        run_command(["auth0", "api", "patch", f"/email-templates/{template}", "--data", json.dumps({
            "enabled": False,
            "from": "",
            "subject": "",
            "body": "",
            "syntax": "liquid",
            "urlLifetimeInSeconds": 432000
        })])

    # Disable MFA factors
    print("🔄 Disabling MFA factors...")
    mfa_factors = ["webauthn-roaming", "otp"]
    for factor in mfa_factors:
        run_command(["auth0", "api", "put", f"/guardian/factors/{factor}", "--data", json.dumps({
            "enabled": False
        })])

    print("✅ Auth0 resources deleted successfully")

if __name__ == "__main__":
    delete_resources()

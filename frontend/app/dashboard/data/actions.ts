import { getSession } from "@auth0/nextjs-auth0"

export async function fetchAppData() {
  const session = await getSession()
  if (!session?.user) {
    throw new Error("Not authenticated")
  }

  try {
    const response = await fetch("http://app-service/api/data", {
      headers: {
        "Authorization": `Bearer ${session.accessToken}`,
      },
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()
    return data
  } catch (error) {
    console.error("Error fetching data:", error)
    throw new Error("Failed to fetch data from app service")
  }
}

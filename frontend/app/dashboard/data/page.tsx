import { Suspense } from "react"
import { TableIcon } from "lucide-react"

import { fetchAppData } from "./actions"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { PageHeader } from "@/components/page-header"

async function DataTable() {
  const { data } = await fetchAppData()

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>ID</TableHead>
          <TableHead>Created At</TableHead>
          <TableHead>Data</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {data.map((item: any) => (
          <TableRow key={item.id}>
            <TableCell>{item.id}</TableCell>
            <TableCell>{new Date(item.created_at).toLocaleString()}</TableCell>
            <TableCell>{JSON.stringify(item.data)}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}

export default function DataPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Sample Data"
        description="Data retrieved from the app service"
      />

      <Card>
        <CardHeader>
          <CardTitle>Recent Data</CardTitle>
          <CardDescription>
            Showing the most recent entries from the database
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Suspense fallback={<div>Loading data...</div>}>
            <DataTable />
          </Suspense>
        </CardContent>
      </Card>
    </div>
  )
}

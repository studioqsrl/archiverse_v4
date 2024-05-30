"use client"

import { useFormStatus } from "react-dom"

import { Button } from "@/components/ui/button"
import { Spinner } from "@/components/spinner"

export function SubmitButton({
  children,
  disabled = false,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement>) {
  const { pending } = useFormStatus()

  return (
    <Button type="submit" disabled={disabled || pending} {...props}>
      {pending && <Spinner className="mr-2 h-4 w-4 animate-spin" />}
      {children}
    </Button>
  )
}

'use client'

import { useState, useEffect } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'sonner'
import { Eye, EyeOff, Loader2, ShieldCheck } from 'lucide-react'
import { resetPassword } from '@/lib/auth'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

// Simple strength labels — no import needed
function getStrength(password: string): { label: string; color: string; width: string } {
  if (password.length < 6)  return { label: 'Too short', color: 'bg-red-500',    width: 'w-1/4' }
  if (password.length < 8)  return { label: 'Weak',      color: 'bg-orange-500', width: 'w-2/4' }
  const hasUpper   = /[A-Z]/.test(password)
  const hasLower   = /[a-z]/.test(password)
  const hasNumber  = /\d/.test(password)
  const hasSpecial = /[^A-Za-z0-9]/.test(password)
  const score = [hasUpper, hasLower, hasNumber, hasSpecial].filter(Boolean).length
  if (score <= 2) return { label: 'Fair',   color: 'bg-yellow-500', width: 'w-3/4' }
  return             { label: 'Strong', color: 'bg-green-500',  width: 'w-full' }
}

const schema = z.object({
  new_password: z
    .string()
    .min(8, 'Must be at least 8 characters')
    .regex(/[A-Z]/, 'Must contain an uppercase letter')
    .regex(/\d/,   'Must contain a number'),
  confirm_password: z.string(),
}).refine((d) => d.new_password === d.confirm_password, {
  message: "Passwords don't match",
  path: ['confirm_password'],
})

type FormData = z.infer<typeof schema>

export default function ResetPasswordPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const token = searchParams.get('token') || ''

  const [showPw, setShowPw]     = useState(false)
  const [done,   setDone]       = useState(false)
  const [watched, setWatched]   = useState('')

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) })

  const pw = watch('new_password', '')
  useEffect(() => { setWatched(pw) }, [pw])

  const strength = getStrength(watched)

  if (!token) {
    return (
      <div className="text-center py-4">
        <p className="text-red-400 text-sm">
          Invalid or missing reset link. Please ask an Admin to regenerate one.
        </p>
      </div>
    )
  }

  async function onSubmit(data: FormData) {
    try {
      const res = await resetPassword(token, data.new_password)
      if (res.success) {
        setDone(true)
        toast.success('Password changed! Please sign in.')
        setTimeout(() => router.push('/login'), 2500)
      } else {
        toast.error(res.message || 'Reset failed.')
      }
    } catch (err: unknown) {
      const e = err as { message?: string }
      toast.error(e.message || 'Reset link may have expired. Ask an Admin for a new one.')
    }
  }

  if (done) {
    return (
      <div className="text-center py-6 space-y-3">
        <ShieldCheck className="w-12 h-12 text-green-400 mx-auto" />
        <h3 className="text-white font-semibold text-lg">Password changed!</h3>
        <p className="text-slate-400 text-sm">Redirecting to sign in…</p>
      </div>
    )
  }

  return (
    <>
      <h2 className="text-xl font-semibold text-white mb-1">Set new password</h2>
      <p className="text-slate-400 text-sm mb-6">Choose a strong password you haven&apos;t used before.</p>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5" noValidate>
        {/* New password */}
        <div className="space-y-1.5">
          <Label htmlFor="new_password" className="text-slate-300 text-sm">New Password</Label>
          <div className="relative">
            <Input
              id="new_password"
              type={showPw ? 'text' : 'password'}
              autoComplete="new-password"
              autoFocus
              disabled={isSubmitting}
              className="bg-white/10 border-white/20 text-white placeholder:text-slate-500 focus-visible:ring-indigo-500 pr-10"
              placeholder="Min. 8 chars, 1 uppercase, 1 number"
              {...register('new_password')}
            />
            <button
              type="button"
              onClick={() => setShowPw((v) => !v)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-200 transition-colors"
              tabIndex={-1}
            >
              {showPw ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
            </button>
          </div>

          {/* Strength bar */}
          {watched.length > 0 && (
            <div className="space-y-1 pt-0.5">
              <div className="h-1.5 w-full bg-white/10 rounded-full overflow-hidden">
                <div className={`h-full rounded-full transition-all duration-300 ${strength.color} ${strength.width}`} />
              </div>
              <p className={`text-xs ${strength.color.replace('bg-', 'text-')}`}>{strength.label}</p>
            </div>
          )}

          {errors.new_password && (
            <p className="text-red-400 text-xs">{errors.new_password.message}</p>
          )}
        </div>

        {/* Confirm password */}
        <div className="space-y-1.5">
          <Label htmlFor="confirm_password" className="text-slate-300 text-sm">Confirm Password</Label>
          <Input
            id="confirm_password"
            type={showPw ? 'text' : 'password'}
            autoComplete="new-password"
            disabled={isSubmitting}
            className="bg-white/10 border-white/20 text-white placeholder:text-slate-500 focus-visible:ring-indigo-500"
            placeholder="Repeat your new password"
            {...register('confirm_password')}
          />
          {errors.confirm_password && (
            <p className="text-red-400 text-xs">{errors.confirm_password.message}</p>
          )}
        </div>

        <Button
          type="submit"
          disabled={isSubmitting}
          className="w-full bg-indigo-600 hover:bg-indigo-500 text-white font-medium"
        >
          {isSubmitting ? (
            <><Loader2 className="w-4 h-4 mr-2 animate-spin" /> Changing password…</>
          ) : (
            'Change password'
          )}
        </Button>
      </form>
    </>
  )
}

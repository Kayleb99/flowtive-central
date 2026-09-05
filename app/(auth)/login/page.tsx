'use client'

import { useState, useEffect } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'sonner'
import { Eye, EyeOff, Loader2, AlertTriangle } from 'lucide-react'
import { login, saveSession, defaultLandingPage, isLoggedIn } from '@/lib/auth'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

const schema = z.object({
  username: z.string().min(1, 'Username is required'),
  password: z.string().min(1, 'Password is required'),
})

type FormData = z.infer<typeof schema>

export default function LoginPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const nextPath = searchParams.get('next') || null

  const [showPassword, setShowPassword] = useState(false)
  const [isLocked, setIsLocked] = useState(false)
  const [lockMessage, setLockMessage] = useState('')

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) })

  // Already logged in? redirect
  useEffect(() => {
    if (isLoggedIn()) {
      router.replace(nextPath || '/pos/dashboard')
    }
  }, [router, nextPath])

  async function onSubmit(data: FormData) {
    try {
      const res = await login(data.username, data.password)

      if (res.force_password_reset && res.reset_token) {
        toast.info('You must set a new password before continuing.')
        router.push(`/reset-password?token=${res.reset_token}`)
        return
      }

      if (res.success && res.user && res.token) {
        saveSession(res.token, res.user)
        toast.success(`Welcome back, ${res.user.full_name.split(' ')[0]}!`)
        router.replace(nextPath || defaultLandingPage(res.user))
      } else {
        toast.error(res.message || 'Login failed. Try again.')
      }
    } catch (err: unknown) {
      const e = err as { status?: number; message?: string }
      if (e.status === 429) {
        setIsLocked(true)
        setLockMessage(e.message || 'Too many attempts. Please wait 15 minutes.')
      } else {
        toast.error(e.message || 'Network error. Check your connection.')
      }
    }
  }

  return (
    <>
      <h2 className="text-xl font-semibold text-white mb-1">Sign in</h2>
      <p className="text-slate-400 text-sm mb-6">Enter your credentials to continue</p>

      {/* Lockout banner */}
      {isLocked && (
        <div className="flex items-start gap-2 bg-red-500/10 border border-red-500/30 rounded-lg p-3 mb-5 text-sm text-red-300">
          <AlertTriangle className="w-4 h-4 mt-0.5 shrink-0" />
          <span>{lockMessage}</span>
        </div>
      )}

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5" noValidate>
        {/* Username */}
        <div className="space-y-1.5">
          <Label htmlFor="username" className="text-slate-300 text-sm">
            Username or Email
          </Label>
          <Input
            id="username"
            type="text"
            autoComplete="username"
            autoFocus
            disabled={isLocked || isSubmitting}
            className="bg-white/10 border-white/20 text-white placeholder:text-slate-500 focus-visible:ring-indigo-500"
            placeholder="e.g. admin"
            {...register('username')}
          />
          {errors.username && (
            <p className="text-red-400 text-xs">{errors.username.message}</p>
          )}
        </div>

        {/* Password */}
        <div className="space-y-1.5">
          <Label htmlFor="password" className="text-slate-300 text-sm">
            Password
          </Label>
          <div className="relative">
            <Input
              id="password"
              type={showPassword ? 'text' : 'password'}
              autoComplete="current-password"
              disabled={isLocked || isSubmitting}
              className="bg-white/10 border-white/20 text-white placeholder:text-slate-500 focus-visible:ring-indigo-500 pr-10"
              placeholder="••••••••"
              {...register('password')}
            />
            <button
              type="button"
              onClick={() => setShowPassword((v) => !v)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-200 transition-colors"
              tabIndex={-1}
              aria-label={showPassword ? 'Hide password' : 'Show password'}
            >
              {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
            </button>
          </div>
          {errors.password && (
            <p className="text-red-400 text-xs">{errors.password.message}</p>
          )}
        </div>

        <Button
          type="submit"
          disabled={isLocked || isSubmitting}
          className="w-full bg-indigo-600 hover:bg-indigo-500 text-white font-medium"
        >
          {isSubmitting ? (
            <><Loader2 className="w-4 h-4 mr-2 animate-spin" /> Signing in…</>
          ) : (
            'Sign in'
          )}
        </Button>
      </form>

      <p className="text-slate-500 text-xs text-center mt-6">
        Forgot your password? Ask an Admin to generate a reset link for you.
      </p>
    </>
  )
}

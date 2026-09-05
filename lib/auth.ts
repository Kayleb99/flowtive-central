/**
 * Flowtive Central — Auth session helpers (client-side)
 * Stores/reads token, user profile, and drives redirect logic.
 */

import { api, LoginResponse, UserProfile } from './api'

const TOKEN_KEY = 'flowtive_token'
const USER_KEY  = 'flowtive_user'

// ─── Token storage ────────────────────────────────────────────────────────────

export function saveSession(token: string, user: UserProfile): void {
  if (typeof localStorage === 'undefined') return
  localStorage.setItem(TOKEN_KEY, token)
  localStorage.setItem(USER_KEY, JSON.stringify(user))
}

export function clearSession(): void {
  if (typeof localStorage === 'undefined') return
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(USER_KEY)
}

export function getStoredToken(): string | null {
  if (typeof localStorage === 'undefined') return null
  return localStorage.getItem(TOKEN_KEY)
}

export function getStoredUser(): UserProfile | null {
  if (typeof localStorage === 'undefined') return null
  try {
    const raw = localStorage.getItem(USER_KEY)
    return raw ? (JSON.parse(raw) as UserProfile) : null
  } catch {
    return null
  }
}

export function isLoggedIn(): boolean {
  return !!getStoredToken()
}

// ─── Role helpers ─────────────────────────────────────────────────────────────

const ROLE_RANK: Record<string, number> = {
  'Super Admin': 5,
  Admin: 4,
  Manager: 3,
  'Inventory Manager': 2,
  Cashier: 1,
}

export function hasRole(user: UserProfile | null, minRole: string): boolean {
  if (!user) return false
  return (ROLE_RANK[user.role] ?? 0) >= (ROLE_RANK[minRole] ?? 0)
}

export function hasModule(user: UserProfile | null, module: string): boolean {
  if (!user) return false
  return user.modules.includes(module)
}

// ─── Module → default landing page ───────────────────────────────────────────

export function defaultLandingPage(user: UserProfile): string {
  if (user.modules.includes('erp')) return '/erp/dashboard'
  if (user.modules.includes('pos')) return '/pos/dashboard'
  if (user.modules.includes('inventory')) return '/inventory/items'
  return '/pos/dashboard'
}

// ─── API calls ────────────────────────────────────────────────────────────────

export async function login(
  username: string,
  password: string
): Promise<LoginResponse> {
  return api.post<LoginResponse>('auth/login.php', { username, password })
}

export async function logout(): Promise<void> {
  try {
    await api.post('auth/logout.php', {})
  } finally {
    clearSession()
  }
}

export async function verifySession(): Promise<UserProfile | null> {
  try {
    const res = await api.get<{ success: boolean; user: UserProfile }>('auth/verify.php')
    return res.success ? res.user : null
  } catch {
    clearSession()
    return null
  }
}

export async function requestPasswordReset(userId: number) {
  return api.post<{ success: boolean; reset_url: string; expires_at: string }>(
    'auth/request-reset.php',
    { user_id: userId }
  )
}

export async function resetPassword(token: string, newPassword: string) {
  return api.post<{ success: boolean; message: string }>('auth/reset-password.php', {
    token,
    new_password: newPassword,
  })
}

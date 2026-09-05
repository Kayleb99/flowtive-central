/**
 * Flowtive Central — Typed API client
 * Wraps fetch with auth token injection, error normalization, and base URL from env.
 */

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost/flowtive-central'

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public data?: unknown
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

function getToken(): string | null {
  if (typeof document === 'undefined') return null
  // Try localStorage first (vanilla HTML compat), then session storage
  return localStorage.getItem('flowtive_token') || sessionStorage.getItem('flowtive_token')
}

async function request<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const token = getToken()
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...(options.headers ?? {}),
  }

  const url = endpoint.startsWith('http') ? endpoint : `${BASE_URL}/api/${endpoint}`

  const res = await fetch(url, {
    ...options,
    headers,
    credentials: 'include', // Send HttpOnly cookie for Next.js frontend
  })

  let data: unknown
  try {
    data = await res.json()
  } catch {
    data = null
  }

  if (!res.ok) {
    const message =
      (data as Record<string, string>)?.message || `HTTP ${res.status}`
    throw new ApiError(message, res.status, data)
  }

  return data as T
}

// ─── Convenience methods ──────────────────────────────────────────────────────

export const api = {
  get: <T>(endpoint: string) => request<T>(endpoint),

  post: <T>(endpoint: string, body: unknown) =>
    request<T>(endpoint, { method: 'POST', body: JSON.stringify(body) }),

  put: <T>(endpoint: string, body: unknown) =>
    request<T>(endpoint, { method: 'PUT', body: JSON.stringify(body) }),

  delete: <T>(endpoint: string, body?: unknown) =>
    request<T>(endpoint, {
      method: 'DELETE',
      ...(body ? { body: JSON.stringify(body) } : {}),
    }),
}

// ─── Typed endpoint helpers ───────────────────────────────────────────────────

export interface ApiResponse<T = unknown> {
  success: boolean
  message?: string
  data?: T
}

export interface LoginResponse {
  success: boolean
  message: string
  user?: UserProfile
  token?: string
  expires_at?: string
  force_password_reset?: boolean
  reset_token?: string
}

export interface UserProfile {
  id: number
  username: string
  full_name: string
  email: string
  mobile: string
  role: string
  modules: string[]
  status: string
  force_password_reset: boolean
  last_login?: string
}

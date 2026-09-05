import { NextRequest, NextResponse } from 'next/server'

// Routes that anyone can access without a session
const PUBLIC_PATHS = ['/login', '/reset-password', '/api/auth']

// Static file extensions to skip
const STATIC_EXT = /\.(?:svg|png|jpg|jpeg|ico|css|js|woff2?)$/i

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Skip static files and Next.js internals
  if (STATIC_EXT.test(pathname) || pathname.startsWith('/_next')) {
    return NextResponse.next()
  }

  // Skip public routes
  if (PUBLIC_PATHS.some((p) => pathname.startsWith(p))) {
    return NextResponse.next()
  }

  // Check for session — prefer HttpOnly cookie, fall back to Authorization header
  const sessionCookie = request.cookies.get('flowtive_session')?.value
  const authHeader    = request.headers.get('authorization')
  const token = sessionCookie || authHeader?.replace('Bearer ', '')

  if (!token) {
    // Redirect to login, preserving the intended destination
    const loginUrl = new URL('/login', request.url)
    loginUrl.searchParams.set('next', pathname)
    return NextResponse.redirect(loginUrl)
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
}

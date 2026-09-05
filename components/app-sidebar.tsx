'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { useState } from 'react'
import {
  LayoutDashboard, ShoppingCart, Package, BarChart3,
  Settings, Users, ChevronLeft, LogOut, TrendingDown,
  ClipboardList, Menu, X
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { logout, getStoredUser } from '@/lib/auth'
import { toast } from 'sonner'

const NAV = [
  { section: 'ERP Hub', module: 'erp', items: [
    { label: 'Dashboard', href: '/erp/dashboard', icon: LayoutDashboard },
    { label: 'Reports',   href: '/erp/reports',   icon: BarChart3 },
    { label: 'Users',     href: '/erp/users',      icon: Users },
    { label: 'Settings',  href: '/erp/settings',   icon: Settings },
  ]},
  { section: 'Point of Sale', module: 'pos', items: [
    { label: 'Dashboard',     href: '/pos/dashboard',    icon: LayoutDashboard },
    { label: 'New Sale',      href: '/pos/new-order',    icon: ShoppingCart },
    { label: 'Sales History', href: '/pos/sales-history',icon: ClipboardList },
  ]},
  { section: 'Inventory', module: 'inventory', items: [
    { label: 'Items',      href: '/inventory/items',     icon: Package },
    { label: 'Categories', href: '/inventory/categories',icon: ClipboardList },
    { label: 'Stock',      href: '/inventory/stock',     icon: TrendingDown },
    { label: 'Low Stock',  href: '/inventory/low-stock', icon: TrendingDown },
  ]},
]

export function AppSidebar({ onClose }: { onClose?: () => void }) {
  const pathname = usePathname()
  const router   = useRouter()
  const user     = getStoredUser()

  async function handleLogout() {
    await logout()
    toast.success('Logged out')
    router.push('/login')
  }

  return (
    <aside className="flex flex-col h-full bg-slate-900 border-r border-slate-800 w-64">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-5 border-b border-slate-800">
        <div className="flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-lg bg-indigo-600 flex items-center justify-center">
            <span className="text-white text-sm font-bold">F</span>
          </div>
          <span className="text-white font-semibold text-sm">Flowtive</span>
        </div>
        {onClose && (
          <button onClick={onClose} className="text-slate-400 hover:text-white lg:hidden">
            <X className="w-5 h-5" />
          </button>
        )}
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto py-4 space-y-6 px-3">
        {NAV.filter(s => user?.modules.includes(s.module)).map(section => (
          <div key={section.section}>
            <p className="text-slate-500 text-xs font-medium uppercase tracking-wider px-2 mb-1">
              {section.section}
            </p>
            {section.items.map(item => {
              const active = pathname.startsWith(item.href)
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={onClose}
                  className={cn(
                    'flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors',
                    active
                      ? 'bg-indigo-600 text-white'
                      : 'text-slate-400 hover:text-white hover:bg-slate-800'
                  )}
                >
                  <item.icon className="w-4 h-4 shrink-0" />
                  {item.label}
                </Link>
              )
            })}
          </div>
        ))}
      </nav>

      {/* User footer */}
      <div className="border-t border-slate-800 p-3">
        <div className="flex items-center gap-3 px-2 py-2">
          <div className="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center text-white text-xs font-semibold">
            {user?.full_name?.[0] ?? 'U'}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-white text-sm font-medium truncate">{user?.full_name ?? 'User'}</p>
            <p className="text-slate-500 text-xs truncate">{user?.role}</p>
          </div>
          <button onClick={handleLogout} title="Log out" className="text-slate-500 hover:text-red-400 transition-colors">
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </aside>
  )
}

export function MobileSidebarToggle({ onClick }: { onClick: () => void }) {
  return (
    <button onClick={onClick} className="lg:hidden text-slate-600 hover:text-slate-900 dark:text-slate-400">
      <Menu className="w-5 h-5" />
    </button>
  )
}

'use client'

import { useEffect, useState } from 'react'
import { ShoppingCart, TrendingUp, Clock, DollarSign } from 'lucide-react'
import { api } from '@/lib/api'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

interface Stats { today_sales: number; today_revenue: number; today_profit: number; pending_debts: number }

function StatCard({ title, value, icon: Icon, color }: { title: string; value: string; icon: React.ElementType; color: string }) {
  return (
    <Card>
      <CardContent className="flex items-center gap-4 p-5">
        <div className={`p-3 rounded-xl ${color}`}>
          <Icon className="w-5 h-5 text-white" />
        </div>
        <div>
          <p className="text-sm text-muted-foreground">{title}</p>
          <p className="text-2xl font-bold">{value}</p>
        </div>
      </CardContent>
    </Card>
  )
}

export default function POSDashboard() {
  const [stats, setStats] = useState<Stats | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get<{ success: boolean; stats: Stats }>('dashboard/index.php?period=today')
      .then(r => setStats(r.stats))
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  const fmt = (n: number) => `KES ${n?.toLocaleString('en-KE', { minimumFractionDigits: 2 }) ?? '0.00'}`

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">POS Dashboard</h1>
        <p className="text-muted-foreground text-sm">Today&apos;s performance</p>
      </div>

      {loading ? (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <Card key={i}><CardContent className="h-24 animate-pulse bg-muted rounded-xl m-4" /></Card>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard title="Today's Sales"   value={String(stats?.today_sales ?? 0)}   icon={ShoppingCart} color="bg-indigo-500" />
          <StatCard title="Revenue"         value={fmt(stats?.today_revenue ?? 0)}      icon={DollarSign}   color="bg-green-500" />
          <StatCard title="Profit"          value={fmt(stats?.today_profit ?? 0)}       icon={TrendingUp}   color="bg-blue-500" />
          <StatCard title="Pending Debts"   value={fmt(stats?.pending_debts ?? 0)}      icon={Clock}        color="bg-orange-500" />
        </div>
      )}

      <Card>
        <CardHeader><CardTitle className="text-base">Quick Actions</CardTitle></CardHeader>
        <CardContent className="flex gap-3 flex-wrap">
          <a href="/pos/new-order" className="inline-flex items-center gap-2 bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors">
            <ShoppingCart className="w-4 h-4" /> New Sale
          </a>
          <a href="/pos/sales-history" className="inline-flex items-center gap-2 bg-slate-100 hover:bg-slate-200 dark:bg-slate-800 dark:hover:bg-slate-700 text-sm font-medium px-4 py-2 rounded-lg transition-colors">
            View History
          </a>
        </CardContent>
      </Card>
    </div>
  )
}
